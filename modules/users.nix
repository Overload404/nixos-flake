{ config, pkgs, ... }:
{
  # =========================================================================
  # User: overload
  # =========================================================================
  users.users.overload = {
    isNormalUser = true;
    initialPassword = "changeme";  # Change on first login!
    shell = pkgs.fish;
    extraGroups = [
      "wheel"           # sudo access
      "video"           # GPU access (DRM, rendering)
      "audio"           # Audio devices
      "networkmanager"  # Manage network connections
      "uinput"          # Sunshine gamepad emulation
      "input"           # Input device access
    ];
  };
}
