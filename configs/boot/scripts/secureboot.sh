#!/bin/bash
# Configure Secure Boot using shim + MOK.
# Distro-agnostic, user-agnostic. Requires systemd-boot.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

MOK_DIR="/etc/secure-boot"

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

    detect_kernels
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

verify_all() {
    info "Verifying all signatures..."
    local failed=false

    for f in "$ESP/EFI/BOOT/grub${EFI_ARCH}.efi" "$ESP/EFI/systemd/grub${EFI_ARCH}.efi"; do
        sudo sbverify --cert "$MOK_DIR/MOK.crt" "$f" &>/dev/null \
            || { echo -e "${RED}  ✗ $(basename "$f") FAILED${NC}"; failed=true; }
    done

    detect_kernels
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

    acquire_sudo "This script configures Secure Boot by modifying the EFI System Partition, generating signing keys, and installing pacman hooks."

    bootctl status &>/dev/null || err "systemd-boot is not the active bootloader"
    detect_esp
    detect_arch
    detect_distro

    info "Detected: distro=$DISTRO_ID arch=$EFI_ARCH ESP=$ESP"

    install_packages
    generate_mok
    backup_esp
    install_shim
    sign_all
    install_hooks
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
