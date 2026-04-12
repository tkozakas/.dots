#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[secureboot]${NC} $1"; }
ok()    { echo -e "${GREEN}[secureboot] ✓${NC} $1"; }
warn()  { echo -e "${YELLOW}[secureboot] !${NC} $1"; }
err()   { echo -e "${RED}[secureboot] ✗${NC} $1"; exit 1; }

MOK_DIR="/etc/secure-boot"

acquire_sudo() {
    echo ""
    echo -e "${YELLOW}This script will configure Secure Boot on your system.${NC}"
    echo -e "${YELLOW}It modifies the EFI System Partition, generates signing keys,${NC}"
    echo -e "${YELLOW}and installs pacman hooks to keep everything signed on updates.${NC}"
    echo ""
    read -rp "Do you trust this script? [y/N] " trust
    [[ "$trust" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }
    echo ""

    sudo -v || err "Failed to acquire sudo credentials"
    # Keep sudo alive in the background for the duration of the script
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT
}

detect_arch() {
    case "$(uname -m)" in
        x86_64)  EFI_ARCH="x64";  EFI_BOOT_NAME="BOOTX64.EFI" ;;
        aarch64) EFI_ARCH="aa64"; EFI_BOOT_NAME="BOOTAA64.EFI" ;;
        *)       err "Unsupported architecture: $(uname -m)" ;;
    esac
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        DISTRO_ID=$(. /etc/os-release && echo "${ID:-unknown}")
    else
        DISTRO_ID="unknown"
    fi
}

pkg_install() {
    case "$DISTRO_ID" in
        arch|manjaro|endeavouros)
            sudo pacman -S --noconfirm --needed "$@" ;;
        fedora|rhel|centos)
            sudo dnf install -y "$@" ;;
        ubuntu|debian|pop|linuxmint)
            sudo apt-get install -y "$@" ;;
        *)
            err "Unsupported distro '$DISTRO_ID' — install manually: $*" ;;
    esac
}

aur_install() {
    local aur_helper=""
    for helper in yay paru; do
        if command -v "$helper" &>/dev/null; then
            aur_helper="$helper"
            break
        fi
    done
    [[ -n "$aur_helper" ]] || err "No AUR helper found (yay/paru). Install shim-signed manually."
    "$aur_helper" -S --noconfirm --needed --sudoloop "$@"
}

detect_shim() {
    local candidates=(
        "/usr/share/shim-signed"
        "/usr/lib/shim"
    )
    SHIM_DIR=""

    for dir in "${candidates[@]}"; do
        if [[ -d "$dir" && -f "$dir/shim${EFI_ARCH}.efi" ]]; then
            SHIM_DIR="$dir"
            SHIM_EFI="$dir/shim${EFI_ARCH}.efi"
            MM_EFI="$dir/mm${EFI_ARCH}.efi"
            return 0
        fi
    done

    if [[ -f "/usr/lib/shim/shimx64.efi.signed" ]]; then
        SHIM_EFI="/usr/lib/shim/shimx64.efi.signed"
        MM_EFI="/usr/lib/shim/mmx64.efi"
        SHIM_DIR="/usr/lib/shim"
        return 0
    fi

    return 1
}

detect_kernels() {
    KERNELS=()
    for k in "$ESP"/vmlinuz-*; do
        [[ -f "$k" ]] && KERNELS+=("$k")
    done
    [[ ${#KERNELS[@]} -gt 0 ]] || err "No kernel images found in $ESP/vmlinuz-*"
}

preflight() {
    [[ -d /sys/firmware/efi ]] || err "System is not booted in UEFI mode"
    bootctl status &>/dev/null || err "systemd-boot is not the active bootloader"

    detect_arch
    detect_distro

    ESP="$(bootctl -p 2>/dev/null)" || ESP="/boot"
    mountpoint -q "$ESP" || err "ESP at $ESP is not mounted"

    info "Detected: distro=$DISTRO_ID arch=$EFI_ARCH ESP=$ESP"
}

install_packages() {
    info "Checking required packages..."

    if ! command -v sbsign &>/dev/null; then
        case "$DISTRO_ID" in
            arch|manjaro|endeavouros) pkg_install sbsigntools ;;
            fedora|rhel|centos)       pkg_install sbsigntools ;;
            ubuntu|debian|pop|linuxmint) pkg_install sbsigntool ;;
            *) err "Install sbsigntools manually for your distro" ;;
        esac
    fi

    if ! command -v mokutil &>/dev/null; then
        pkg_install mokutil
    fi

    if ! detect_shim; then
        case "$DISTRO_ID" in
            arch|manjaro|endeavouros)
                aur_install shim-signed ;;
            fedora|rhel|centos)
                pkg_install "shim-${EFI_ARCH}" ;;
            ubuntu|debian|pop|linuxmint)
                pkg_install shim-signed ;;
            *) err "Install shim-signed manually for your distro" ;;
        esac
        detect_shim || err "shim-signed installed but EFI binaries not found"
    fi

    ok "Packages ready (sbsign, mokutil, shim)"
}

generate_mok() {
    if [[ -f "$MOK_DIR/MOK.key" && -f "$MOK_DIR/MOK.crt" && -f "$MOK_DIR/MOK.cer" ]]; then
        ok "MOK keypair already exists"
    else
        info "Generating MOK keypair (4096-bit RSA, 10-year validity)..."
        sudo mkdir -p "$MOK_DIR"
        sudo openssl req -newkey rsa:4096 -nodes \
            -keyout "$MOK_DIR/MOK.key" \
            -new -x509 -sha256 -days 3650 \
            -subj "/CN=Machine Owner Key $(hostname -s)" \
            -out "$MOK_DIR/MOK.crt" 2>/dev/null
        sudo openssl x509 -outform DER -in "$MOK_DIR/MOK.crt" -out "$MOK_DIR/MOK.cer"
        ok "MOK keypair generated"
    fi

    sudo chmod 700 "$MOK_DIR"
    sudo chmod 600 "$MOK_DIR/MOK.key"
    sudo chmod 644 "$MOK_DIR/MOK.crt" "$MOK_DIR/MOK.cer"
}

backup_esp() {
    if [[ -d "$ESP/EFI.bak" ]]; then
        ok "ESP backup already exists"
        return
    fi
    info "Backing up $ESP/EFI/ ..."
    sudo cp -a "$ESP/EFI" "$ESP/EFI.bak.tmp"
    sudo mv "$ESP/EFI.bak.tmp" "$ESP/EFI.bak"
    ok "ESP backed up (atomic)"
}

install_shim() {
    info "Installing shim + MokManager to ESP..."
    sudo mkdir -p "$ESP/EFI/BOOT" "$ESP/EFI/systemd"

    sudo cp "$SHIM_EFI" "$ESP/EFI/BOOT/$EFI_BOOT_NAME"
    sudo cp "$MM_EFI"   "$ESP/EFI/BOOT/mm${EFI_ARCH}.efi"
    sudo cp "$SHIM_EFI" "$ESP/EFI/systemd/shim${EFI_ARCH}.efi"
    sudo cp "$MM_EFI"   "$ESP/EFI/systemd/mm${EFI_ARCH}.efi"

    ok "shim + MokManager installed"
}

sign_efi() {
    local input="$1" output="$2"

    if sudo sbverify --cert "$MOK_DIR/MOK.crt" "$input" &>/dev/null; then
        ok "$(basename "$output") already signed — skipping"
        return
    fi

    sudo sbsign --key "$MOK_DIR/MOK.key" --cert "$MOK_DIR/MOK.crt" \
        --output "$output" "$input"
}

sign_all() {
    local sdboot="$ESP/EFI/systemd/systemd-boot${EFI_ARCH}.efi"
    [[ -f "$sdboot" ]] || err "systemd-boot not found at $sdboot — run 'bootctl install' first"

    info "Signing systemd-boot..."
    sign_efi "$sdboot" "$ESP/EFI/BOOT/grub${EFI_ARCH}.efi"
    sign_efi "$sdboot" "$ESP/EFI/systemd/grub${EFI_ARCH}.efi"
    ok "systemd-boot signed"

    detect_kernels
    for kernel in "${KERNELS[@]}"; do
        info "Signing $(basename "$kernel")..."
        sign_efi "$kernel" "$kernel"
    done
    ok "All kernels signed (${#KERNELS[@]} total)"

    sudo cp "$MOK_DIR/MOK.cer" "$ESP/MOK.cer"
    ok "MOK.cer placed on ESP for enrollment"
}

install_hooks() {
    case "$DISTRO_ID" in
        arch|manjaro|endeavouros) ;;
        *)
            warn "Non-Arch distro — skipping pacman hooks."
            warn "Sign kernels manually after updates or add a hook for your package manager."
            return ;;
    esac

    local hooks_dst="/etc/pacman.d/hooks"
    sudo mkdir -p "$hooks_dst"

    local kernel_targets=""
    for kernel in "${KERNELS[@]}"; do
        local kname
        kname="$(basename "$kernel")"
        kname="${kname#vmlinuz-}"
        kernel_targets+="Target = $kname"$'\n'
    done

    sudo tee "$hooks_dst/99-secureboot.hook" > /dev/null << HOOK
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
${kernel_targets}
[Action]
Description = Signing kernel(s) for Secure Boot...
When = PostTransaction
Exec = /bin/sh -c 'for k in ${ESP}/vmlinuz-*; do /usr/bin/sbsign --key ${MOK_DIR}/MOK.key --cert ${MOK_DIR}/MOK.crt --output "\$k" "\$k"; done'
Depends = sbsigntools
HOOK

    sudo tee "$hooks_dst/98-secureboot-systemd.hook" > /dev/null << HOOK
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = systemd

[Action]
Description = Signing systemd-boot for Secure Boot...
When = PostTransaction
Exec = /bin/sh -c '/usr/bin/sbsign --key ${MOK_DIR}/MOK.key --cert ${MOK_DIR}/MOK.crt --output ${ESP}/EFI/systemd/grub${EFI_ARCH}.efi ${ESP}/EFI/systemd/systemd-boot${EFI_ARCH}.efi && /usr/bin/sbsign --key ${MOK_DIR}/MOK.key --cert ${MOK_DIR}/MOK.crt --output ${ESP}/EFI/BOOT/grub${EFI_ARCH}.efi ${ESP}/EFI/systemd/systemd-boot${EFI_ARCH}.efi'
Depends = sbsigntools
HOOK

    ok "Pacman hooks installed"
}

setup_windows_entry() {
    if ! command -v efibootmgr &>/dev/null; then
        warn "efibootmgr not found — skipping Windows boot entry setup"
        return
    fi

    # Find Windows Boot Manager UEFI entry and extract its disk/partition
    local win_entry
    win_entry=$(efibootmgr -v 2>/dev/null | grep -i "Windows Boot Manager" || true)
    [[ -n "$win_entry" ]] || { info "No Windows Boot Manager found in UEFI — skipping"; return; }

    # Extract the GPT partition UUID of the Windows ESP from the UEFI entry
    local win_partuuid
    win_partuuid=$(echo "$win_entry" | grep -oP 'GPT,\K[0-9a-f-]+' | head -1)
    [[ -n "$win_partuuid" ]] || { warn "Could not parse Windows ESP partition UUID"; return; }

    # Find the block device for that partition
    local win_dev
    win_dev=$(lsblk -o NAME,PARTUUID -rn 2>/dev/null | awk -v uuid="$win_partuuid" '$2==uuid {print "/dev/"$1}')
    [[ -n "$win_dev" ]] || { warn "Could not find device for Windows ESP (PARTUUID=$win_partuuid)"; return; }

    # Determine the Linux ESP partition UUID to compare
    local linux_esp_partuuid
    linux_esp_partuuid=$(lsblk -o MOUNTPOINT,PARTUUID -rn 2>/dev/null | awk -v esp="$ESP" '$1==esp {print $2}')

    if [[ "$win_partuuid" == "$linux_esp_partuuid" ]]; then
        info "Windows ESP is the same as Linux ESP — no copy needed"
    else
        info "Windows is on a separate ESP ($win_dev) — copying bootloader..."
        local tmp_mnt
        tmp_mnt=$(mktemp -d)
        sudo mount -o ro "$win_dev" "$tmp_mnt"
        if [[ -f "$tmp_mnt/EFI/Microsoft/Boot/bootmgfw.efi" ]]; then
            sudo mkdir -p "$ESP/EFI/Microsoft/Boot"
            sudo cp "$tmp_mnt/EFI/Microsoft/Boot/bootmgfw.efi" "$ESP/EFI/Microsoft/Boot/bootmgfw.efi"
            ok "Windows bootloader copied to Linux ESP"
        else
            warn "bootmgfw.efi not found on Windows ESP — skipping"
        fi
        sudo umount "$tmp_mnt" && rmdir "$tmp_mnt"
    fi

    # Create systemd-boot entry if Windows EFI exists on our ESP
    if [[ -f "$ESP/EFI/Microsoft/Boot/bootmgfw.efi" ]]; then
        if [[ ! -f "$ESP/loader/entries/windows.conf" ]]; then
            sudo tee "$ESP/loader/entries/windows.conf" > /dev/null << ENTRY
title   Windows Boot Manager
efi     /EFI/Microsoft/Boot/bootmgfw.efi
ENTRY
            ok "systemd-boot Windows entry created"
        else
            ok "systemd-boot Windows entry already exists"
        fi
    fi
}

setup_boot_order() {
    if ! command -v efibootmgr &>/dev/null; then
        return
    fi

    # Find the boot entry that points to our ESP's BOOTX64.EFI (Linux/shim)
    local linux_num
    linux_num=$(efibootmgr 2>/dev/null | grep "UEFI OS" | grep -oP 'Boot\K[0-9A-F]+' | head -1)
    [[ -n "$linux_num" ]] || linux_num=$(efibootmgr 2>/dev/null | grep -i "Linux" | grep -oP 'Boot\K[0-9A-F]+' | head -1)
    [[ -n "$linux_num" ]] || { info "Could not identify Linux UEFI entry — boot order unchanged"; return; }

    local current_order
    current_order=$(efibootmgr 2>/dev/null | grep "^BootOrder:" | awk '{print $2}')
    local first_entry="${current_order%%,*}"

    if [[ "$first_entry" == "$linux_num" ]]; then
        ok "Linux is already first in UEFI boot order"
    else
        # Build new order: linux first, then everything else
        local other_entries
        other_entries=$(echo "$current_order" | tr ',' '\n' | grep -v "^${linux_num}$" | tr '\n' ',' | sed 's/,$//')
        local new_order="${linux_num}"
        [[ -n "$other_entries" ]] && new_order="${linux_num},${other_entries}"
        sudo efibootmgr --bootorder "$new_order" &>/dev/null
        ok "UEFI boot order set: Linux first ($new_order)"
    fi
}

verify_all() {
    info "Verifying all signatures..."
    local failed=false

    for f in "$ESP/EFI/BOOT/grub${EFI_ARCH}.efi" "$ESP/EFI/systemd/grub${EFI_ARCH}.efi"; do
        sudo sbverify --cert "$MOK_DIR/MOK.crt" "$f" &>/dev/null \
            || { echo -e "${RED}  ✗ $(basename "$f") FAILED${NC}"; failed=true; }
    done

    for kernel in "${KERNELS[@]}"; do
        sudo sbverify --cert "$MOK_DIR/MOK.crt" "$kernel" &>/dev/null \
            || { echo -e "${RED}  ✗ $(basename "$kernel") FAILED${NC}"; failed=true; }
    done

    $failed && err "Signature verification failed — DO NOT enable Secure Boot"
    ok "All signatures verified"
}

main() {
    echo ""
    info "Secure Boot setup (shim + MOK)"
    acquire_sudo

    preflight
    install_packages
    generate_mok
    backup_esp
    install_shim
    sign_all
    install_hooks
    setup_windows_entry
    setup_boot_order
    verify_all

    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN} Secure Boot setup complete${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  Boot chain:"
    echo "    UEFI → shim${EFI_ARCH}.efi (Microsoft-signed)"
    echo "         → grub${EFI_ARCH}.efi (systemd-boot, MOK-signed)"
    echo "         → vmlinuz-* (MOK-signed)"
    echo ""
    echo -e "  ${YELLOW}Next steps (physical access required):${NC}"
    echo "  1. Reboot → BIOS → Enable Secure Boot"
    echo "  2. Boot Arch → MokManager launches automatically"
    echo "  3. Enroll key from disk → select MOK.cer"
    echo "  4. Set one-time password → reboot → enter password"
    echo ""
    echo "  Verify: mokutil --sb-state"
    echo ""
}

main "$@"
