{ config, pkgs, lib, ... }:

let
  dotfiles = ./dotfiles;

  # Helper to force-override an xdg.configFile entry (for files that
  # conflict with home-manager module-generated configs like fish,
  # waybar, and btop).
  forceCfg = path: lib.mkForce { source = "${dotfiles}/${path}"; };
  forceCfgExec = path:
    lib.mkForce { source = "${dotfiles}/${path}"; executable = true; };

  # Non-forced helpers
  cfg = path: { source = "${dotfiles}/${path}"; };
  cfgExec = path: { source = "${dotfiles}/${path}"; executable = true; };
in
{
  # =========================================================================
  # Home Manager State Version
  # =========================================================================
  home.stateVersion = "25.11";

  # =========================================================================
  #  1. Shells
  # =========================================================================

  # --- Fish ---
  programs.fish = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      la = "ls -lah";
      homestow = "stow -t ~";
    };
    shellInit = ''
      set -gx EDITOR nvim
      set -gx STOW_DIR "$HOME/.dotfiles/"
      set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
      set -gx QT_QPA_PLATFORMTHEME qt6ct
      set -gx OPENCODE_ENABLE_EXA 1
      set -gx WOW_DIR "$HOME/Games/Heroic/Prefixes/default/Battle.net/pfx/drive_c/Program Files (x86)/World of Warcraft/_retail_/WTF"
      set -gx WOW_CLASSIC_DIR "$HOME/Games/Heroic/Prefixes/default/Battle.net/pfx/drive_c/Program Files (x86)/World of Warcraft/_classic_era_/WTF"
    '';
    # NOTE: The shellInit above is a fallback. The primary fish configuration
    # is deployed from dotfiles/fish/ via xdg.configFile below, which
    # overrides (via lib.mkForce) the home-manager-generated config.fish.
    # The dotfiles/fish/config.fish already contains all aliases, env vars,
    # path additions, tmux auto-start, .env sourcing, and starship init.
  };

  # --- Bash ---
  programs.bash = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      la = "ls -lah";
    };
  };

  # --- Zsh ---
  programs.zsh = {
    enable = true;
    shellAliases = {
      vim = "nvim";
      la = "ls -lah";
    };
  };

  # --- Nushell ---
  # NOTE: The nushell home-manager module may not exist in older versions
  # of home-manager. If it is missing, comment out this block and deploy
  # the nushell config files via xdg.configFile below instead.
  programs.nushell = {
    enable = true;
    configFile.source = "${dotfiles}/nushell/config.nu";
    envFile.source = "${dotfiles}/nushell/env.nu";
  };

  # =========================================================================
  #  2. Starship Prompt
  # =========================================================================
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./dotfiles/starship.toml);
    # NOTE: The starship module adds its own init snippet to shells.
    # If the dotfiles/fish/config.fish also contains "starship init fish | source",
    # you may get duplicate prompt rendering. Remove that line from
    # dotfiles/fish/config.fish if you use the starship module here.
  };

  # =========================================================================
  #  3. Git
  # =========================================================================
  programs.git = {
    enable = true;
    userName = "overload404";
    userEmail = "53265117+Overload404@users.noreply.github.com";
    extraConfig.init.defaultBranch = "master";
  };

  # =========================================================================
  #  4. Tmux
  # =========================================================================
  programs.tmux = {
    enable = true;
    prefix = "C-s";
    baseIndex = 1;
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = builtins.readFile ./dotfiles/tmux/.tmux.conf;
    # NOTE: The extraConfig above reads the full .tmux.conf, which includes
    # plugin configuration for tpm (Tmux Plugin Manager). You will need to
    # install tpm separately (git clone) or disable the plugin lines.
  };

  # =========================================================================
  #  5. Foot Terminal
  # =========================================================================
  programs.foot = {
    enable = true;
    settings.main = {
      font = "JetBrainsMono Nerd Font Mono:size=13";
      pad = "1x3x0x0";
      dpi-aware = "yes";
    };
    # NOTE: The original foot.ini includes a theme (gruvbox-dark).
    # Foot themes are installed by the foot package to
    # /run/current-system/sw/share/foot/themes/ and can be included
    # via an include= directive if needed.
  };

  # =========================================================================
  #  6. Btop
  # =========================================================================
  programs.btop = {
    enable = true;
    # Full config deployed from dotfiles via xdg.configFile below
    # (programs.btop.extraConfig is NOT set here to avoid duplication;
    # the xdg.configFile entry overrides the module-generated btop.conf).
  };

  # =========================================================================
  #  7. Mako Notification Daemon
  # =========================================================================
  services.mako = {
    enable = true;
    defaultTimeout = 10000;
    backgroundColor = "#3c3836dd";
    textColor = "#ebdbb2";
    borderColor = "#928374";
    borderRadius = 7;
    maxIconSize = 48;
    maxVisible = 10;
    anchor = "top-right";
    margin = "20";
    layer = "top";
    font = "Sarasa UI SC 10";
    icons = true;
    extraConfig = ''
      on-button-left=invoke-default-action

      [app-name="screenshot"]
      on-button-left=exec swappy -f /tmp/screenshot-last.png

      [urgency=low]
      border-color=#b8bb26

      [urgency=normal]
      border-color=#fabd2f

      [urgency=high]
      border-color=#fb4934
    '';
  };

  # =========================================================================
  #  8. Waybar
  # =========================================================================
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    # Empty settings/style: the actual config files are deployed from
    # dotfiles via xdg.configFile below (with mkForce to override the
    # module-generated empty config.jsonc / style.css).
    settings = lib.mkForce { };
    style = lib.mkForce "";
  };

  # =========================================================================
  #  9. GTK
  # =========================================================================
  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Material-Dark-HIDPI";
      # Uncomment if the package is available in your nixpkgs:
      # package = pkgs.gruvbox-material-gtk;
      # Alternative search names in nixpkgs:
      #   pkgs.gruvbox-dark-gtk, pkgs.gruvbox-material-gtk-theme
    };
    iconTheme = {
      name = "Gruvbox-Plus-Light";
      # Uncomment if available:
      # package = pkgs.gruvbox-plus-icons;
    };
    cursorTheme = {
      name = "Future-cursors";
      size = 36;
      # Uncomment if available in nixpkgs (e.g. pkgs.graphite-cursors):
      # package = pkgs.graphite-cursors;
    };
    font = {
      name = "Noto Sans";
      size = 10;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-button-images = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    # NOTE: Additional GTK CSS overrides are deployed from dotfiles/
    # via xdg.configFile below (gtk-3.0/gtk.css, gtk-4.0/gtk.css, etc.).
    # The settings.ini files are managed by the gtk module above.
  };

  # =========================================================================
  # XDG Config Files (dotfiles -> ~/.config/)
  # =========================================================================
  xdg.configFile = {
    # -- Fish (complete directory, overrides module-generated config.fish) --
    # IMPORTANT: Using lib.mkForce on config.fish because the
    # home-manager programs.fish module also writes to this path.
    "fish/config.fish" = forceCfg "fish/config.fish";
    "fish/fish_plugins" = cfg "fish/fish_plugins";
    "fish/completions/fisher.fish" = cfg "fish/completions/fisher.fish";
    "fish/completions/stalker-gamma.fish" =
      cfg "fish/completions/stalker-gamma.fish";
    "fish/functions/fisher.fish" = cfg "fish/functions/fisher.fish";
    "fish/functions/_puffer_fish_expand_star.fish" =
      cfg "fish/functions/_puffer_fish_expand_star.fish";
    "fish/functions/_puffer_fish_expand_dot.fish" =
      cfg "fish/functions/_puffer_fish_expand_dot.fish";
    "fish/functions/_puffer_fish_expand_buck.fish" =
      cfg "fish/functions/_puffer_fish_expand_buck.fish";
    "fish/functions/_puffer_fish_expand_bang.fish" =
      cfg "fish/functions/_puffer_fish_expand_bang.fish";
    "fish/conf.d/puffer_fish_key_bindings.fish" =
      cfg "fish/conf.d/puffer_fish_key_bindings.fish";
    "fish/conf.d/00_fig_pre.fish" = cfg "fish/conf.d/00_fig_pre.fish";
    "fish/conf.d/99_fig_post.fish" = cfg "fish/conf.d/99_fig_post.fish";
    "fish/conf.d/tide_theme.fish" = cfg "fish/conf.d/tide_theme.fish";

    # -- Hyprland (Lua config -- no home-manager Lua support) --
    "hypr/hyprland.lua" = cfg "hypr/hyprland.lua";
    "hypr/apps.lua" = cfg "hypr/apps.lua";
    "hypr/autostart.lua" = cfg "hypr/autostart.lua";
    "hypr/keybinds.lua" = cfg "hypr/keybinds.lua";
    "hypr/window_rules.lua" = cfg "hypr/window_rules.lua";
    "hypr/workspace_rules.lua" = cfg "hypr/workspace_rules.lua";
    "hypr/devices.lua" = cfg "hypr/devices.lua";
    "hypr/animations.lua" = cfg "hypr/animations.lua";
    "hypr/env_vars.lua" = cfg "hypr/env_vars.lua";
    "hypr/passthrough.lua" = cfg "hypr/passthrough.lua";
    "hypr/general.lua" = cfg "hypr/general.lua";
    "hypr/hyprpaper.conf" = cfg "hypr/hyprpaper.conf";
    "hypr/monitors/dell.lua" = cfg "hypr/monitors/dell.lua";
    "hypr/monitors/samsung.lua" = cfg "hypr/monitors/samsung.lua";
    # Additional hypr files present in dotfiles (not in original spec,
    # but useful for full config):
    "hypr/hl.meta.lua" = cfg "hypr/hl.meta.lua";
    "hypr/hyprqt6engine.conf" = cfg "hypr/hyprqt6engine.conf";

    # -- Hyprland scripts (executable) --
    "hypr/scripts/screenshot_area" = cfgExec "hypr/scripts/screenshot_area";
    "hypr/scripts/screenshot_full" = cfgExec "hypr/scripts/screenshot_full";
    "hypr/scripts/q_chat_with_dir.sh" =
      cfgExec "hypr/scripts/q_chat_with_dir.sh";
    # Additional scripts from dotfiles:
    "hypr/scripts/screenshot" = cfgExec "hypr/scripts/screenshot";
    "hypr/scripts/rotate_monitor.sh" =
      cfgExec "hypr/scripts/rotate_monitor.sh";

    # -- Waybar (config + scripts, override module-generated stubs) --
    # Using lib.mkForce because programs.waybar also writes config.jsonc
    # and style.css (even with empty settings/style).
    "waybar/config.jsonc" = forceCfg "waybar/config.jsonc";
    "waybar/style.css" = forceCfg "waybar/style.css";
    "waybar/colors/gruvbox.css" = cfg "waybar/colors/gruvbox.css";

    # -- Waybar scripts (executable) --
    "waybar/vram.sh" = cfgExec "waybar/vram.sh";
    "waybar/PLVPN.sh" = cfgExec "waybar/PLVPN.sh";
    "waybar/USVPN.sh" = cfgExec "waybar/USVPN.sh";
    "waybar/kill-openvpn.sh" = cfgExec "waybar/kill-openvpn.sh";
    "waybar/updates.sh" = cfgExec "waybar/updates.sh";
    "waybar/updates-read.sh" = cfgExec "waybar/updates-read.sh";
    "waybar/modules/storage.sh" = cfgExec "waybar/modules/storage.sh";
    "waybar/modules/weather.sh" = cfgExec "waybar/modules/weather.sh";
    # Additional waybar modules from dotfiles:
    "waybar/modules/mail.py" = cfgExec "waybar/modules/mail.py";
    "waybar/modules/spotify.sh" = cfgExec "waybar/modules/spotify.sh";
    "waybar/colors/rose-pine-moon.css" =
      cfg "waybar/colors/rose-pine-moon.css";

    # -- Wlogout --
    "wlogout/layout" = cfg "wlogout/layout";
    "wlogout/style.css" = cfg "wlogout/style.css";
    "wlogout/colors/gruvbox.css" = cfg "wlogout/colors/gruvbox.css";
    "wlogout/colors/rose-pine-moon.css" =
      cfg "wlogout/colors/rose-pine-moon.css";

    # -- LACT (AMD GPU control) --
    "lact/ui.yaml" = cfg "lact/ui.yaml";

    # -- Sunshine (game streaming) --
    "sunshine/apps.json" = cfg "sunshine/apps.json";
    "sunshine/sunshine.conf" = cfg "sunshine/sunshine.conf";

    # -- Btop (overrides module-generated btop.conf) --
    "btop/btop.conf" = forceCfg "btop/btop.conf";

    # -- GTK CSS overrides (settings.ini is managed by the gtk module above) --
    "gtk-3.0/colors.css" = cfg "gtk-3.0/colors.css";
    "gtk-3.0/gtk.css" = cfg "gtk-3.0/gtk.css";
    "gtk-4.0/colors.css" = cfg "gtk-4.0/colors.css";
    "gtk-4.0/gtk.css" = cfg "gtk-4.0/gtk.css";
  };

  # =========================================================================
  # Home Files (non-XDG)
  # =========================================================================
  home.file.".wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink
    "/home/overload/.wallpapers";
  # NOTE: The wallpapers directory must already exist at /home/overload/.wallpapers
  # before building. This creates a symlink from ~/.wallpapers into the Nix store
  # so Hyprpaper can reference wallpapers.

  # =========================================================================
  # Systemd User Services
  # =========================================================================
  systemd.user.services.ssh-agent = {
    Unit = {
      Description = "SSH key agent";
    };
    Service = {
      Type = "simple";
      Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.waybar-updates = {
    Unit = {
      Description = "Check for NixOS updates and notify waybar";
    };
    Service = {
      Type = "oneshot";
      ExecStart =
        "${config.home.homeDirectory}/.config/waybar/updates.sh";
    };
  };

  systemd.user.timers.waybar-updates = {
    Unit = {
      Description = "Hourly NixOS update check for waybar";
    };
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1h";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # =========================================================================
  # Additional Home Packages
  # =========================================================================
  home.packages = with pkgs; [
    # Shell prompt (also configured via programs.starship above; the
    # package is needed even when the module handles the config)
    starship

    # Terminal multiplexer (also configured via programs.tmux above)
    tmux


  ];
}
