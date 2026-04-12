#!/bin/bash
# Set Linux as the first entry in UEFI boot order.
# Detects the Linux/shim boot entry and moves it to the front.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

main() {
    echo ""
    info "UEFI boot order setup"

    if ! command -v efibootmgr &>/dev/null; then
        warn "efibootmgr not found — cannot configure boot order"
        exit 0
    fi

    # Find the Linux boot entry (typically "UEFI OS" or contains "Linux")
    local linux_num
    linux_num=$(efibootmgr 2>/dev/null | grep "UEFI OS" | grep -oP 'Boot\K[0-9A-F]+' | head -1)
    [[ -n "$linux_num" ]] || linux_num=$(efibootmgr 2>/dev/null | grep -i "Linux" | grep -oP 'Boot\K[0-9A-F]+' | head -1)

    if [[ -z "$linux_num" ]]; then
        info "Could not identify Linux UEFI entry — boot order unchanged"
        exit 0
    fi

    local current_order
    current_order=$(efibootmgr 2>/dev/null | grep "^BootOrder:" | awk '{print $2}')
    local first_entry="${current_order%%,*}"

    if [[ "$first_entry" == "$linux_num" ]]; then
        ok "Linux is already first in UEFI boot order"
        exit 0
    fi

    acquire_sudo "This script sets Linux as the first entry in the UEFI boot order."

    # Build new order: linux first, then everything else
    local other_entries
    other_entries=$(echo "$current_order" | tr ',' '\n' | grep -v "^${linux_num}$" | tr '\n' ',' | sed 's/,$//')
    local new_order="${linux_num}"
    [[ -n "$other_entries" ]] && new_order="${linux_num},${other_entries}"

    sudo efibootmgr --bootorder "$new_order" &>/dev/null
    ok "UEFI boot order set: Linux first ($new_order)"
    echo ""
}

main "$@"
