#!/usr/bin/env bash
# NixOS Installer — overrig (RX 9060 XT)
# Single-script installer for NixOS from the live ISO.
# Clones the Overload404/nixos-flake flake and performs a full install.
#
# Usage:
#   curl -LO https://raw.githubusercontent.com/Overload404/nixos-flake/master/install.sh
#   sudo bash install.sh
#
# Or directly (prompts still work via /dev/tty):
#   curl -sL https://raw.githubusercontent.com/Overload404/nixos-flake/master/install.sh | sudo bash

set -euo pipefail

# ──────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ok()     { echo -e "  ${GREEN}Done ✓${NC}"; }
warn()   { echo -e "  ${YELLOW}⚠  $*${NC}"; }
die()    { echo -e "\n${RED}╔══════════════════════════════════════╗${NC}" >&2
           echo -e   "${RED}║  ERROR: $*${NC}" >&2
           echo -e   "${RED}╚══════════════════════════════════════╝${NC}\n" >&2
           exit 1; }
header() { echo -e "\n${BOLD}━━━ $* ━━━${NC}"; }
info()   { echo -e "  ${GREEN}→${NC} $*"; }

# Detect piped stdin (curl ... | bash) and explain the fix
if [[ ! -t 0 ]]; then
    echo -e "${YELLOW}Note: stdin is piped. All prompts will use /dev/tty for input.${NC}" >&2
    echo "" >&2
fi

# ──────────────────────────────────────────────
# Banner
# ──────────────────────────────────────────────
echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════╗"
echo "║                                              ║"
echo "║         NixOS Installer — overrig             ║"
echo "║         (RX 9060 XT / AMD RDNA4)              ║"
echo "║                                              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# ──────────────────────────────────────────────
# Parse flags
# ──────────────────────────────────────────────
SKIP_PARTITION=false
for arg in "$@"; do
    case "$arg" in
        --skip-partition|-s)
            SKIP_PARTITION=true
            shift
            ;;
        --help|-h)
            echo "Usage: curl -sL <url> | bash"
            echo "       bash install.sh [--skip-partition]"
            echo ""
            echo "  --skip-partition  Skip disk selection, partitioning, formatting,"
            echo "                    and mounting. Assumes /mnt is already set up."
            exit 0
            ;;
        *)
            die "Unknown argument: $arg"
            ;;
    esac
done

# ──────────────────────────────────────────────
# 1. Pre-flight checks
# ──────────────────────────────────────────────
header "Pre-flight checks"

# Verify we're on a NixOS live ISO
if ! command -v nixos-version &>/dev/null && ! test -f /etc/NIXOS; then
    die "This script must be run from a NixOS live ISO.\n  Boot the NixOS live USB and try again."
fi
info "Running on NixOS live environment"

# Require root
if [[ $EUID -ne 0 ]]; then
    die "This script must be run as root.\n  Run: sudo bash install.sh"
fi
ok

# ──────────────────────────────────────────────
# 2. Internet check
# ──────────────────────────────────────────────
header "Network check"

if ! ping -c 2 -W 3 github.com &>/dev/null; then
    echo -e "${RED}No internet connection detected.${NC}"
    echo ""
    echo "Set up Wi-Fi with wpa_supplicant:"
    echo "  sudo wpa_cli"
    echo "  > add_network"
    echo "  > set_network 0 ssid \"YOUR_SSID\""
    echo "  > set_network 0 psk \"YOUR_PASSWORD\""
    echo "  > enable_network 0"
    echo "  > quit"
    echo ""
    echo "Then re-run this script."
    die "No internet connection"
fi
info "Internet connection verified"
ok

# ──────────────────────────────────────────────
# 3. Disk selection & partitioning
# ──────────────────────────────────────────────
if $SKIP_PARTITION; then
    header "Skipping partition (--skip-partition)"

    # Verify /mnt is mounted
    if ! findmnt /mnt &>/dev/null; then
        die "/mnt is not mounted. Did you forget to mount your root partition?\n  Mount your root partition to /mnt and re-run with --skip-partition."
    fi
    info "/mnt is mounted — proceeding with existing layout"
else
    header "Disk Selection"

    # Show available disks
    echo ""
    echo -e "${BOLD}Available disks:${NC}"
    echo ""
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL 2>/dev/null | head -1
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL -d 2>/dev/null || lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL 2>/dev/null
    echo ""

    # Ask which disk
    echo -ne "${BOLD}Which disk to install to? (e.g., nvme0n1, sda): ${NC}"
    read -r DISK < /dev/tty

    # Validate disk exists
    if [[ ! -b "/dev/$DISK" ]]; then
        die "/dev/$DISK does not exist. Check the name with lsblk and try again."
    fi

    # Confirm
    echo ""
    echo -e "${RED}${BOLD}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║  WARNING: This will DESTROY ALL DATA on     ║${NC}"
    echo -e "${RED}${BOLD}║           /dev/$DISK                         ║${NC}"
    echo -e "${RED}${BOLD}╚══════════════════════════════════════════════╝${NC}"
    echo ""

    echo -ne "${BOLD}Type 'YES' (uppercase) to confirm: ${NC}"
    read -r CONFIRM < /dev/tty
    if [[ "$CONFIRM" != "YES" ]]; then
        die "Aborted by user."
    fi

    # Determine partition naming scheme
    # NVMe drives: /dev/nvme0n1p1, /dev/nvme0n1p2
    # SATA/VirtIO: /dev/sda1,   /dev/sda2
    if [[ "$DISK" == nvme* ]] || [[ "$DISK" == mmcblk* ]]; then
        PART_PREFIX="p"
    else
        PART_PREFIX=""
    fi

    EFI_PART="/dev/${DISK}${PART_PREFIX}1"
    ROOT_PART="/dev/${DISK}${PART_PREFIX}2"

    # ── Partition ──────────────────────────
    header "Partitioning /dev/$DISK"

    info "Creating GPT partition table..."
    parted "/dev/$DISK" -- mklabel gpt || die "Failed to create GPT label on /dev/$DISK"

    info "Creating EFI system partition (512 MiB)..."
    parted "/dev/$DISK" -- mkpart ESP fat32 1MiB 513MiB || die "Failed to create EFI partition"
    parted "/dev/$DISK" -- set 1 esp on || die "Failed to set ESP flag"

    info "Creating root partition (remainder of disk)..."
    parted "/dev/$DISK" -- mkpart primary ext4 513MiB 100% || die "Failed to create root partition"

    # Let the kernel re-read the partition table
    info "Waiting for kernel to re-read partition table..."
    partprobe "/dev/$DISK" 2>/dev/null || true
    sleep 2

    # Verify partitions were created
    if [[ ! -b "$EFI_PART" ]]; then
        die "EFI partition $EFI_PART not found after partitioning.\n  Try running partprobe or rebooting the live ISO."
    fi
    if [[ ! -b "$ROOT_PART" ]]; then
        die "Root partition $ROOT_PART not found after partitioning."
    fi
    ok

    # ── Format ─────────────────────────────
    header "Formatting partitions"

    info "Formatting EFI partition ($EFI_PART) as FAT32..."
    mkfs.fat -F 32 "$EFI_PART" || die "Failed to format $EFI_PART"

    info "Formatting root partition ($ROOT_PART) as ext4..."
    mkfs.ext4 -F "$ROOT_PART" || die "Failed to format $ROOT_PART"
    ok

    # ── Mount ──────────────────────────────
    header "Mounting filesystems"

    if findmnt /mnt &>/dev/null; then
        warn "/mnt is already mounted — skipping mount"
    else
        info "Mounting root partition to /mnt..."
        mount "$ROOT_PART" /mnt || die "Failed to mount $ROOT_PART to /mnt"
    fi

    info "Creating /mnt/boot..."
    mkdir -p /mnt/boot

    if findmnt /mnt/boot &>/dev/null; then
        warn "/mnt/boot is already mounted — skipping mount"
    else
        info "Mounting EFI partition to /mnt/boot..."
        mount "$EFI_PART" /mnt/boot || die "Failed to mount $EFI_PART to /mnt/boot"
    fi
    ok
fi

# ──────────────────────────────────────────────
# 4. Clone the flake
# ──────────────────────────────────────────────
header "Cloning configuration"

# Ensure /mnt/etc exists
mkdir -p /mnt/etc

# Remove old clone if it exists (from a previous failed attempt)
if [[ -d /mnt/etc/nixos ]]; then
    warn "Removing existing /mnt/etc/nixos from a previous attempt..."
    rm -rf /mnt/etc/nixos
fi

info "Cloning Overload404/nixos-flake..."
nix-shell -p git --run "git clone https://github.com/Overload404/nixos-flake.git /mnt/etc/nixos" \
    || die "Failed to clone the configuration repository.\n  Check your internet connection and that the repo is public."

ok

# ──────────────────────────────────────────────
# 5. Generate hardware configuration
# ──────────────────────────────────────────────
header "Generating hardware configuration"

info "Running nixos-generate-config..."
nixos-generate-config --root /mnt || die "Hardware config generation failed.\n  This is unusual — check that your disk is properly mounted."

# Verify the file was produced
if [[ ! -f /mnt/etc/nixos/hardware-configuration.nix ]]; then
    die "hardware-configuration.nix was not generated in /mnt/etc/nixos/"
fi

info "Hardware configuration generated"
ok

# ──────────────────────────────────────────────
# 6. Install NixOS
# ──────────────────────────────────────────────
header "NixOS Installation"

echo ""
echo -e "${BOLD}The nixos-install command will now run.${NC}"
echo "This will build the system from the flake and install it."
echo "It may take 10-30 minutes depending on your internet speed and hardware."
echo ""

# nixos-install will prompt for the root password interactively.
# We use --no-root-password and set it ourselves for a cleaner UX.
info "Starting nixos-install (this is the long step)..."
echo ""

nixos-install --flake "/mnt/etc/nixos#overrig" --no-root-password \
    || die "nixos-install failed.\n  Check the output above for errors.\n  You can fix issues and re-run with --skip-partition."

ok

# ──────────────────────────────────────────────
# 7. Set passwords
# ──────────────────────────────────────────────
header "User Setup"

echo ""
echo -e "${BOLD}Set the password for the 'overload' user.${NC}"

# Set user password interactively via nixos-enter
nixos-enter --root /mnt -c "passwd overload" \
    || die "Failed to set password for user 'overload'."

# Set root password
echo ""
echo -e "${BOLD}Set the root password.${NC}"
nixos-enter --root /mnt -c "passwd root" \
    || die "Failed to set root password."

ok

# ──────────────────────────────────────────────
# 8. Done
# ──────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║                                              ║${NC}"
echo -e "${GREEN}${BOLD}║       NixOS installation complete!            ║${NC}"
echo -e "${GREEN}${BOLD}║                                              ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Host${NC}:         overrig"
echo -e "  ${BOLD}User${NC}:         overload"
echo -e "  ${BOLD}Config${NC}:       /etc/nixos (from Overload404/nixos-flake)"
echo ""

echo -ne "${BOLD}Reboot now? [y/N] ${NC}"
read -r REBOOT < /dev/tty
case "$REBOOT" in
    [yY]|[yY][eE][sS])
        echo ""
        info "Rebooting in 3 seconds..."
        sleep 3
        reboot
        ;;
    *)
        echo ""
        echo "To reboot manually:"
        echo "  $ reboot"
        echo ""
        echo "When the system comes up, log in as 'overload' with the"
        echo "password you just set. Your configuration lives at /etc/nixos."
        echo ""
        echo "To rebuild after changes:"
        echo "  $ cd ~/repos/nixos-flake   # or wherever you keep the repo"
        echo "  $ sudo nixos-rebuild switch --flake .#overrig"
        ;;
esac
