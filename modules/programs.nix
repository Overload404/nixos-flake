{ config, pkgs, ... }:
{
  # =========================================================================
  # Programs
  # =========================================================================

  # ---------------------------------------------------------------------------
  # Steam (gaming)
  # ---------------------------------------------------------------------------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Steam Remote Play
  };

  # ---------------------------------------------------------------------------
  # Shells
  # ---------------------------------------------------------------------------
  programs.fish.enable = true;
  programs.zsh.enable = true;
  # Note: no programs.nushell module exists in nixpkgs; nushell is
  # installed via environment.systemPackages in packages.nix

  # ---------------------------------------------------------------------------
  # Terminal: Foot
  # ---------------------------------------------------------------------------
  programs.foot.enable = true;

  # ---------------------------------------------------------------------------
  # Editor: Neovim (provides default editor integration)
  # ---------------------------------------------------------------------------
  programs.neovim.enable = true;

  # ---------------------------------------------------------------------------
  # Yazi: terminal file manager integration
  # ---------------------------------------------------------------------------
  programs.yazi.enable = true;

  # ---------------------------------------------------------------------------
  # Tmux: terminal multiplexer integration
  # ---------------------------------------------------------------------------
  programs.tmux.enable = true;

  # ---------------------------------------------------------------------------
  # XDG Desktop Portal: screen sharing, file picker, etc.
  # ---------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "hyprland" "gtk" ];
  };
}
