{ config, pkgs,lib, ... }:
let
  # Fetch nixGL
  nixGL = import (lib.fetchGit {
    url ="https://github.com/nix-community/nixGL.git";
    ref = "main";
  }) {};

  # Create a wrapper script for launching Kitty with nixGL
  kitty-wrapped = pkgs.writeShellScriptBin "kitty-wrapped" ''
    ${nixGL}/bin/nixGL ${pkgs.kitty}/bin/kitty "$@"
  '';
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "markus";
  home.homeDirectory = "/home/markus";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
  home.language = {
    base = "en_US.UTF-8";
  };
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    EDITOR = "vim";
  };
  home.sessionPath = [
    "/usr/lib/locale"
  ];
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    git
    vim
    wofi
    kitty
    grim  # screenshot tool
    slurp  # screen area selection tool
    wl-clipboard  # clipboard tool
    libGLU
    nil
    meson
    cmake
    pkg-config
    glfw
    libva
    libva-utils
    onedrive
    vscode 
    spotify
    bitwarden-desktop
    jetbrains-mono
    pkgs.python312
    pyenv
    pkgs.python312Packages.pip
    pkgs.python312Packages.virtualenv
    direnv
    sway
    swaylock
    waybar
    pavucontrol
  ];
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  # home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  # };
   home.file = {
  ".config/onedrive/sync_list" = {
      text = ''
        Personlig
        Semester 9
        Semester 8
        Semester 7
        Semester 6
      '';
    };
  };
  # Manage the OneDrive systemd service file
  home.file.".config/systemd/user/onedrive.service" = {
    text = ''
      [Unit]
      Description=OneDrive Free Client for Linux
      After=network-online.target

      [Service]
      ExecStart=%h/.nix-profile/bin/onedrive --monitor
      Restart=on-failure
      RestartSec=3

      [Install]
      WantedBy=default.target
    '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/markus/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
  # ... your existing variables ...
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "iHD";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };
  programs.git = {
    enable = true;
    package = pkgs.git;
    userName = "Kvello";
    userEmail = "markus.kv1@gmail.com";
    extraConfig = {
      core = {
        editor = "vim";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = lib.readFile ./bashrc_extra.sh;
  };
  # Enable Sway
  wayland.windowManager.sway = {
    enable = true;
    config = {
      # Sway configuration options
      modifier = "Mod4"; # Use the Windows key as the modifier
      terminal = "${pkgs.kitty}/bin/kitty"; # You can change this to your preferred terminal
      menu = "${pkgs.dmenu}/bin/dmenu_run";

      # Define key bindings
      keybindings = {
        "${config.wayland.windowManager.sway.config.modifier}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
        "${config.wayland.windowManager.sway.config.modifier}+d" = "exec ${config.wayland.windowManager.sway.config.menu}";
        "${config.wayland.windowManager.sway.config.modifier}+Shift+q" = "kill";
        "${config.wayland.windowManager.sway.config.modifier}+Shift+e" = "exit";
      };

      # Basic status bar configuration
      bars = [{
        position = "bottom";
        statusCommand = "${pkgs.i3status}/bin/i3status";
      }];
    };
  };
  # Waybar configuration
  programs.waybar = {
    enable = true;
    settings = [{
      height = 30;
      modules-left = ["sway/workspaces" "sway/mode"];
      modules-center = ["sway/window"];
      modules-right = ["pulseaudio" "network" "cpu" "memory" "temperature" "clock" "tray"];
      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = true;
      };
      "clock" = {
        format-alt = "{:%Y-%m-%d}";
      };
      "cpu" = {
        format = "{usage}% ";
      };
      "memory" = {
        format = "{}% ";
      };
      "temperature" = {
        critical-threshold = 80;
        format = "{temperatureC}°C ";
      };
      "network" = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
        format-disconnected = "Disconnected ⚠";
      };
      "pulseaudio" = {
        format = "{volume}% {icon}";
        format-bluetooth = "{volume}% {icon}";
        format-muted = "";
        format-icons = {
          headphones = "";
          handsfree = "";
          headset = "";
          phone = "";
          portable = "";
          car = "";
          default = ["" ""];
        };
        on-click = "pavucontrol";
      };
    }];
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "DejaVu Sans Mono", "FontAwesome 5 Free";
        font-size: 13px;
        min-height: 0;
      }
      window#waybar {
        background: rgba(43, 48, 59, 0.5);
        border-bottom: 3px solid rgba(100, 114, 125, 0.5);
        color: white;
      }
      #workspaces button {
        padding: 0 5px;
        background: transparent;
        color: white;
        border-bottom: 3px solid transparent;
      }
      #workspaces button.focused {
        background: #64727D;
        border-bottom: 3px solid white;
      }
      #mode, #clock, #battery {
        padding: 0 10px;
        margin: 0 5px;
      }
      #mode {
        background: #64727D;
        border-bottom: 3px solid white;
      }
    '';
  };
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.njpwerner.autodocstring
      pkgs.vscode-extensions.github.copilot
      pkgs.vscode-extensions.github.copilot-chat
      pkgs.vscode-extensions.jdinhlife.gruvbox
      pkgs.vscode-extensions.jnoortheen.nix-ide
      pkgs.vscode-extensions.mkhl.direnv
      pkgs.vscode-extensions.arrterian.nix-env-selector
      pkgs.vscode-extensions.mhutchie.git-graph
    ];
    userSettings = {
      "files.autoSave" =  "onFocusChange";
      "workbench.colorTheme" = "Gruvbox Dark Soft";

      "editor.fontFamily" =  "JetBrains Mono, Consolas, 'Courier New', monospace";
      "editor.fontSize" =  14;
      "editor.fontWeight" = "normal";
      "editor.lineHeight" = 22;
      "editor.letterSpacing" =  0.5;
      "terminal.integrated.defaultProfile.linux" = "bash";
      "terminal.integrated.profiles.linux" = {
        bash = {
          path = "/bin/bash";
          args = ["-l"];
        };
      };
      "terminal.integrated.env.linux" = {
        BASH_ENV = "\${HOME}/.bashrc";
      };
    };
  };
  programs.spotify-player = {
    enable = true;
  };
  programs.pyenv = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
