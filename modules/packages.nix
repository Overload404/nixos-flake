{ config, pkgs, ... }:
{
  # =========================================================================
  # System-wide Packages
  # =========================================================================
  environment.systemPackages = with pkgs; [

    # -----------------------------------------------------------------------
    # Shells
    # -----------------------------------------------------------------------
    fish
    bash
    zsh
    nushell

    # -----------------------------------------------------------------------
    # Terminal
    # -----------------------------------------------------------------------
    foot
    alacritty

    # -----------------------------------------------------------------------
    # WM / Wayland Compositor
    # -----------------------------------------------------------------------
    hyprland
    hyprpaper
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk

    # -----------------------------------------------------------------------
    # Bar / Notifications / Overlay
    # -----------------------------------------------------------------------
    waybar
    mako               # Notification daemon
    wob                # Wayland overlay bar (volume/brightness OSD)

    # -----------------------------------------------------------------------
    # Launcher / Menu / Logout
    # -----------------------------------------------------------------------
    wofi               # Application launcher
    wlogout            # Logout/shutdown menu

    # -----------------------------------------------------------------------
    # Clipboard / Screenshots
    # -----------------------------------------------------------------------
    wl-clipboard       # Wayland clipboard (wl-copy / wl-paste)
    grim               # Screenshot grabber
    slurp              # Region selector
    swappy             # Screenshot annotation

    # -----------------------------------------------------------------------
    # Lock / Idle
    # -----------------------------------------------------------------------
    swaylock           # Screen locker
    swayidle           # Idle management

    # -----------------------------------------------------------------------
    # Core Applications
    # -----------------------------------------------------------------------
    neovim             # Editor
    btop               # System monitor
    yazi               # Terminal file manager
    tmux               # Terminal multiplexer
    zeal               # Offline documentation browser
    starship           # Shell prompt
    mpv                # Media player
    pavucontrol        # Audio control GUI

    # -----------------------------------------------------------------------
    # Chat / Communication
    # -----------------------------------------------------------------------
    equibop            # Discord client
    telegram-desktop
    signal-desktop

    # -----------------------------------------------------------------------
    # Browser
    # -----------------------------------------------------------------------

    # -----------------------------------------------------------------------
    # Gaming
    # -----------------------------------------------------------------------
    steam              # Steam client
    heroic             # Heroic Games Launcher (Epic/GOG)

    # -----------------------------------------------------------------------
    # Audio control (CLI)
    # -----------------------------------------------------------------------
    pamixer            # PulseAudio/ALSA CLI mixer
    playerctl          # MPRIS media player controller

    # -----------------------------------------------------------------------
    # Brightness control
    # -----------------------------------------------------------------------
    brightnessctl

    # -----------------------------------------------------------------------
    # Network / Bluetooth applets
    # -----------------------------------------------------------------------
    networkmanagerapplet
    blueman

    # -----------------------------------------------------------------------
    # Polkit agent (fallback for environments without built-in agent)
    # -----------------------------------------------------------------------
    polkit_gnome

    # -----------------------------------------------------------------------
    # Input Method: Fcitx5
    # -----------------------------------------------------------------------
    fcitx5
    qt6Packages.fcitx5-configtool
    fcitx5-gtk
    qt6Packages.fcitx5-qt
    qt6.qtwayland      # Qt6 Wayland platform plugin

    # -----------------------------------------------------------------------
    # VPN
    # -----------------------------------------------------------------------
    openvpn

    # -----------------------------------------------------------------------
    # Fonts
    # -----------------------------------------------------------------------
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    sarasa-gothic

    # -----------------------------------------------------------------------
    # Utilities
    # -----------------------------------------------------------------------
    gnome-calculator
    libnotify
    wl-screenrec       # Wayland screen recorder
    qt6Packages.qt6ct              # Qt6 theme/platform config (fish sets QT_QPA_PLATFORMTHEME=qt6ct)
    libsForQt5.qt5ct   # Qt5 theme/platform config

    # -----------------------------------------------------------------------
    # Image Viewer
    # -----------------------------------------------------------------------
    imv                # Simple image viewer

    # -----------------------------------------------------------------------
    # Desktop / Keyring
    # -----------------------------------------------------------------------
    gnome-keyring      # Secrets / keyring daemon
    seahorse           # GUI for keyring management
    nwg-look           # GTK theme switcher for wlroots
  ];

  # ---------------------------------------------------------------------------
  # Fonts: generate font directory and install font packages
  # ---------------------------------------------------------------------------
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      sarasa-gothic
    ];
  };
}
