#!/bin/bash
# Add Windows Boot Manager to systemd-boot menu.
# Auto-detects Windows on same or separate ESP. Safe to run without Windows.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

main() {
    echo ""
    info "Windows boot entry setup"

    detect_esp

    if ! command -v efibootmgr &>/dev/null; then
        warn "efibootmgr not found — cannot detect Windows"
        exit 0
    fi

    # Find Windows Boot Manager UEFI entry
    local win_entry
    win_entry=$(efibootmgr -v 2>/dev/null | grep -i "Windows Boot Manager" || true)
    if [[ -z "$win_entry" ]]; then
        info "No Windows Boot Manager found in UEFI — nothing to do"
        exit 0
    fi

    acquire_sudo "This script copies the Windows bootloader to your ESP and creates a systemd-boot menu entry."

    # Extract the GPT partition UUID of the Windows ESP
    local win_partuuid
    win_partuuid=$(echo "$win_entry" | grep -oP 'GPT,\K[0-9a-f-]+' | head -1)
    [[ -n "$win_partuuid" ]] || { warn "Could not parse Windows ESP partition UUID"; exit 0; }

    # Find the block device for that partition
    local win_dev
    win_dev=$(lsblk -o NAME,PARTUUID -rn 2>/dev/null | awk -v uuid="$win_partuuid" '$2==uuid {print "/dev/"$1}')
    [[ -n "$win_dev" ]] || { warn "Could not find device for Windows ESP (PARTUUID=$win_partuuid)"; exit 0; }

    # Compare with Linux ESP
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
            sudo umount "$tmp_mnt" && rmdir "$tmp_mnt"
            exit 0
        fi
        sudo umount "$tmp_mnt" && rmdir "$tmp_mnt"
    fi

    # Create systemd-boot entry
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

    echo ""
}

main "$@"
