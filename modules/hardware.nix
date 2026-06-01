{ config, pkgs, lib, ... }:
{
  # =========================================================================
  # AMD RX 9060 XT (16GB) - RDNA4 GPU Configuration
  # =========================================================================

  # ---------------------------------------------------------------------------
  # Graphics: enable hardware acceleration and 32-bit support (for Steam)
  # ---------------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    # Mesa OpenGL/Vulkan drivers + AMDVLK (fallback) + VA-API
    extraPackages = with pkgs; [
      mesa.drivers
      amdvlk
      libva
      libva-utils
      vaapiVdpau
    ];

    # 32-bit packages for Steam and legacy games
    extraPackages32 = with pkgs.pkgsi686Linux; [
      mesa.drivers
      amdvlk
    ];
  };

  # ---------------------------------------------------------------------------
  # Force RADV (Mesa Vulkan driver) over AMDVLK for better performance
  # ---------------------------------------------------------------------------
  environment.variables.AMD_VULKAN_ICD = "RADV";

  # ---------------------------------------------------------------------------
  # AMDGPU: OpenCL compute (ROCm), early KMS, overdrive (OC/UV via LACT)
  # ---------------------------------------------------------------------------
  hardware.amdgpu = {
    opencl.enable = true;     # ROCm/OpenCL for compute workloads
    initrd.enable = true;     # Early KMS for flicker-free boot
    overdrive.enable = true;  # Allow LACT to control clocks/voltage
  };

  # ---------------------------------------------------------------------------
  # CPU microcode: AMD CPU updates
  # ---------------------------------------------------------------------------
  hardware.cpu.amd.updateMicrocode = true;

  # ---------------------------------------------------------------------------
  # Firmware: linux-firmware for GPU, WiFi, etc.
  # ---------------------------------------------------------------------------
  hardware.firmware = [ pkgs.linux-firmware ];

  # ---------------------------------------------------------------------------
  # uinput: required by Sunshine for gamepad/input streaming
  # ---------------------------------------------------------------------------
  hardware.uinput.enable = true;
}
