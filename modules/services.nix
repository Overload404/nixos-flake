{ config, pkgs, lib, ... }:
{
  # =========================================================================
  # Services
  # =========================================================================

  # ---------------------------------------------------------------------------
  # Audio: PipeWire (modern Linux audio server)
  # ---------------------------------------------------------------------------
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;              # PulseAudio compatibility
    wireplumber.enable = true;        # Session manager
    alsa = {
      enable = true;
      support32Bit = true;            # 32-bit ALSA for legacy apps
    };
    jack.enable = false;              # JACK not needed
  };

  # Disable PulseAudio (PipeWire provides pulse server)
  hardware.pulseaudio.enable = lib.mkForce false;

  # Real-time priority for audio
  security.rtkit.enable = true;

  # ---------------------------------------------------------------------------
  # Display Manager: Ly (TUI login manager)
  # ---------------------------------------------------------------------------
  services.xserver.enable = true; # Required by Ly

  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
      hide_borders = true;
      hide_version_string = true;
      clear_password = true;
    };
  };

  # Default session: Hyprland via UWSM (recommended for modern Hyprland)
  services.displayManager.defaultSession = "hyprland-uwsm";

  # ---------------------------------------------------------------------------
  # Network: NetworkManager
  # ---------------------------------------------------------------------------
  networking.networkmanager.enable = true;

  # ---------------------------------------------------------------------------
  # Input Method: Fcitx5 (for CJK input)
  # ---------------------------------------------------------------------------
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-qt
    ];
    fcitx5.waylandFrontend = true;
  };

  # ---------------------------------------------------------------------------
  # Sunshine: Game streaming server (Moonlight host)
  # ---------------------------------------------------------------------------
  services.sunshine = {
    enable = true;
    autoStart = true;
    openFirewall = true;  # Open required ports
    capSysAdmin = true;   # Allow sys_admin capability (encoder control)
  };

  # ---------------------------------------------------------------------------
  # LACT: AMD GPU overclocking/undervolting daemon
  # ---------------------------------------------------------------------------
  services.lact.enable = true;

  # ---------------------------------------------------------------------------
  # GVfs: Virtual filesystem (trash, mount, etc.) for GTK/file managers
  # ---------------------------------------------------------------------------
  services.gvfs.enable = true;

  # ---------------------------------------------------------------------------
  # UDisks2: Disk management / mounting
  # ---------------------------------------------------------------------------
  services.udisks2.enable = true;

  # ---------------------------------------------------------------------------
  # Bluetooth
  # ---------------------------------------------------------------------------
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;   # Auto-enable on boot
  };

  # ---------------------------------------------------------------------------
  # Polkit: Privilege escalation framework
  # ---------------------------------------------------------------------------
  security.polkit.enable = true;
}
