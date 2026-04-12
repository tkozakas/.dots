#!/bin/bash
# Shared utilities for boot scripts.
# Source this file, do not execute it directly.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[boot]${NC} $1"; }
ok()    { echo -e "${GREEN}[boot] ✓${NC} $1"; }
warn()  { echo -e "${YELLOW}[boot] !${NC} $1"; }
err()   { echo -e "${RED}[boot] ✗${NC} $1"; exit 1; }

acquire_sudo() {
    local msg="${1:-This script requires elevated privileges.}"
    echo ""
    echo -e "${YELLOW}${msg}${NC}"
    echo ""
    read -rp "Do you trust this script? [y/N] " trust
    [[ "$trust" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }
    echo ""

    sudo -v || err "Failed to acquire sudo credentials"
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT
}

detect_esp() {
    [[ -d /sys/firmware/efi ]] || err "System is not booted in UEFI mode"
    ESP="$(bootctl -p 2>/dev/null)" || ESP="/boot"
    mountpoint -q "$ESP" || err "ESP at $ESP is not mounted"
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
    [[ -n "$aur_helper" ]] || err "No AUR helper found (yay/paru). Install the package manually."
    "$aur_helper" -S --noconfirm --needed --sudoloop "$@"
}
