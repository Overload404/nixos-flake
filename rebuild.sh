#!/usr/bin/env bash
set -euo pipefail

# ── change to the flake root (script's own directory) ──
cd "$(dirname "$0")"

# ── ANSI colour codes ──
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # no colour

# ── helpers ──
ok()    { echo -e "${GREEN}Done ✓${NC}"; }
warn()  { echo -e "${YELLOW}WARNING: $*${NC}"; }
die()   { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }
header(){ echo -e "\n${BOLD}==> $*${NC}"; }
step()  { echo -e "${BOLD}==> $*${NC}"; }

step "NixOS Flake Rebuild"

# ── routing ──
CMD="${1:-update}"

case "$CMD" in

  update)
    # 1. git pull (fast-forward only)
    header "Pulling latest changes..."
    if git pull --ff-only 2>&1; then
      ok
    else
      warn "git pull failed — continuing anyway"
    fi

    # 2. flake update
    header "Updating flake inputs..."
    nix flake update
    ok

    # 3. rebuild + switch
    header "Rebuilding system..."
    sudo nixos-rebuild switch --flake .#overrig
    ok

    # 4. garbage collect system
    header "Cleaning up old generations..."
    sudo nix-collect-garbage --delete-older-than 14d
    home-manager expire-generations -14d
    ok

    # 5. disk usage
    header "Disk usage"
    nix store info

    # 6. push prompt
    echo
    read -r -p "Push changes to git? [y/N]: " REPLY
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      exec "$0" push
    fi
    ;;

  switch)
    header "Rebuilding and switching..."
    sudo nixos-rebuild switch --flake .#overrig
    ok
    ;;

  boot)
    header "Building and adding to boot menu..."
    sudo nixos-rebuild boot --flake .#overrig
    ok
    echo -e "${GREEN}System will appear in boot menu. Reboot to test.${NC}"
    ;;

  dry)
    header "Running flake check..."
    nix flake check
    ok

    header "Dry-activating..."
    sudo nixos-rebuild dry-activate --flake .#overrig
    ok
    ;;

  clean)
    header "Garbage collecting old generations..."
    sudo nix-collect-garbage --delete-older-than 14d
    home-manager expire-generations -14d
    ok

    header "Disk usage"
    nix store info
    ;;

  push)
    header "Checking for changes..."

    # Determine if there is anything to commit
    if [[ -n "$(git status --porcelain)" ]]; then
      git add -A
      read -r -p "Commit message: " MSG
      if [[ -z "$MSG" ]]; then
        die "Commit message cannot be empty"
      fi
      git commit -m "$MSG"
      ok
    else
      echo "No changes to commit. ✓"
    fi

    # Determine if there are commits to push
    git remote update >/dev/null 2>&1
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")
    BASE=$(git merge-base @ @{u} 2>/dev/null || echo "")

    if [[ "$LOCAL" == "$REMOTE" ]]; then
      echo -e "${GREEN}Nothing to push.${NC}"
    elif [[ -n "$BASE" && "$LOCAL" == "$BASE" ]]; then
      die "Remote is ahead of local — pull first"
    else
      header "Pushing..."
      git push
      ok
    fi
    ;;

  check)
    header "Running flake check..."
    nix flake check
    ok
    ;;

  *)
    die "Unknown command: '$CMD'\nUsage: $0 {update|switch|boot|dry|clean|push|check}"
    ;;
esac
