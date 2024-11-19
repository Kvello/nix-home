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
  # Create a wrapper script for launching Sway with nixGL
  sway-wrapped = pkgs.writeShellScriptBin "sway-wrapped" ''
    ${nixGL}/bin/nixGL ${pkgs.sway}/bin/sway "$@"
  '';
  vscode-utils = pkgs.vscode-utils;

  mathworks.language-matlab = vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "language-matlab";
      publisher = "MathWorks";
      version = "1.2.0";
      hash = "sha256-mJE8x+KACHxtU/+Ls2fdX8WY9mkersmcNSmzS+QZ4zU=";
    };
    meta = {
      changelog = "https://marketplace.visualstudio.com/items/MathWorks.language-matlab/changelog";
      description = "MATLAB extension for Visual Studio Code";
      downloadPage = "https://marketplace.visualstudio.com/items?itemName=MathWorks.language-matlab";
      homepage = "https://github.com/mathworks/MATLAB-extension-for-vscode";
      license = lib.licenses.mit;
      maintainers = [];
    };
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "markus";
  home.homeDirectory = "/home/markus";
  home.keyboard.layout = "no";
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
  home.packages = with pkgs; [
    git
    vim
    wofi
    kitty
    texliveFull
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
    glibc
    firefox
    logseq
    inotify-tools
    slack
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5.qtbase
    libsForQt5.qt5.qtx11extras
    iosevka
    font-awesome
    fish
    pywal
    noto-fonts-monochrome-emoji
    font-manager
    zotero
    arandr
    (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; })
  ];
    fonts.fontconfig = {
      enable = true;
    };
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
    "${config.home.homeDirectory}/.config/onedrive/sync_list" = {
      text = ''
        Personlig
        Semester 9
        Semester 8
        Semester 7
        Semester 6
      '';
    };
    "${config.home.homeDirectory}/.config/onedrive/config" = {
      text = ''
        monitor_interval = "60"
        monitor_fullscan_frequency= "120"
      '';
    };
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
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "iHD";
    MOZ_ENABLE_WAYLAND = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    LOGSEQ_DIR = "$HOME/logseq";
    LOGSEQ_SYNC_ADDR = "git@github.com:Kvello/logseq.git";
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
    bashrcExtra = lib.readFile ../dotfiles/bashrc_extra.sh;
  };
  programs.kitty = {
    enable = true;
    extraConfig = lib.readFile ../dotfiles/kitty/kitty.conf;
  };
  programs.pywal.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_color_command ebdbb2 
      set -g fish_color_error d75f5f
      set -g tide_character_color afaf00
      set -g tide_character_color_failure d75f5f
      set -g tide_left_prompt_items os pwd git
      set -g tide_left_prompt_frame_enabled true
      set -g tide_left_prompt_prefix '''
      set -g tide_left_prompt_suffix 
      set -g tide_prompt_pad_items true
      set -g tide_left_prompt_separator_diff_color 
      set -g tide_left_prompt_separator_same_color 
      set -g tide_pwd_bg_color 83adad
      set -g tide_git_bg_color ffaf00
      set -g tide_git_color_branch 262626
      set -g tide_git_bg_color_unstable d75f5f
      set -g tide_git_bg_color_urgent d75f5f
      set -g tide_os_bg_color ebdbb2
      set -g tide_pwd_color_dirs ebdbb2
      set -g tide_pwd_color_anchors ebdbb2
      '';
    plugins = [
      {
        name ="tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "a34b0c2809f665e854d6813dd4b052c1b32a32b4";
          sha256 = "09v3qj4w3r8b0nr598gpf503amaba12485v9mx2pwx9idbyj88b7";
        };
      }
      {
        name="bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "7aae6a85c24660422ea3f3f4629bb4a8d30df3ba";
          sha256 = "03693ywczzr46dgpnbawcfv02v5l143dqlz1fzjbhpwwc2xpr42y";
        };
      }
    ];
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
      ms-vscode.cpptools
      ms-vscode.cmake-tools
      twxs.cmake
      ms-python.python
      vscodevim.vim
      njpwerner.autodocstring
      github.copilot
      github.copilot-chat
      jdinhlife.gruvbox
      jnoortheen.nix-ide
      mkhl.direnv
      arrterian.nix-env-selector
      mhutchie.git-graph
      pkief.material-icon-theme
      james-yu.latex-workshop 
      ms-vscode-remote.remote-ssh
      mathworks.language-matlab 
    ];
    userSettings = {
      "files.autoSave" =  "onFocusChange";
      "workbench.colorTheme" = "Gruvbox Dark Soft";
      "workbench.iconTheme" = "material-icon-theme";
      "material-icon-theme.files.associations" =  {
    
      };
      "MATLAB.installPath"= "/usr/local/MATLAB/R2024a"; #OBS! Not managed with home-manager(yet)
      "latex-workshop.latex.tools"= [
	{
            name = "mkdir";
            command= "mkdir";
            args= [
		"-p"
		"build"
            ];
	}
	{
            name = "pdflatex";
            command= "pdflatex";
            args= [
                "-synctex=1"
                "-interactions=nonstopmode"
                "-file-line-error"
                "-output-directory=build"
                "%DOC%"
            ];
	}
      ];
      "latex-workshop.latex.recipes"= [
          {
              name="pdflatex";
              tools=[
		"mkdir"
		"pdflatex"
              ];
          }
      ];
      "editor.fontFamily" =  "JetBrains Mono, Consolas, 'Courier New', monospace";
      "editor.fontSize" =  14;
      "editor.fontWeight" = "normal";
      "editor.lineHeight" = 22;
      "editor.letterSpacing" =  0.5;
      "terminal.integrated.defaultProfile.linux" = "bash";
      "terminal.integrated.profiles.linux" = {
        bash = {
          path = "${pkgs.bashInteractive}/bin/bash";
          args = ["-l"];
        };
      };
      "terminal.integrated.env.linux" = {
        BASH_ENV = "~/.bashrc";
      };
    };
    keybindings = [
      {
        key = "tab";
        command = "selectNextSuggestion";
        when = "suggestWidgetVisible";
      }
      {
        key = "shift+tab";
        command = "selectPrevSuggestion";
        when = "suggestWidgetVisible";
      }
      {
        key = "enter";
        command = "acceptSelectedSuggestion";
        when = "suggestWidgetVisible && !inlineSuggestionVisible";
      }
      {
        key = "shift+enter";
        command = "type";
        args = ''{ text: \n}'';
        when = "suggestWidgetVisible";
      } 
      {
        key = "tab";
        command = "-acceptSelectedSuggestion";
        when = "suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && textInputFocus";
      }
      {
        key = "right";
        command= "editor.action.inlineEdit.accept";
        when= "cursorAtInlineEdit && inlineEditVisible && !editorReadonly";
       }
       {
         key= "tab";
         command= "-editor.action.inlineEdit.accept";
         when= "cursorAtInlineEdit && inlineEditVisible && !editorReadonly";
       }
    ];
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

  # Ensure systemd user services are enabled
  systemd.user.enable = true;

  # Define the existing OneDrive service
  systemd.user.services = {
    onedrive = {
      Unit = {
        Description = "OneDrive synchronization service";
      };
      Service = {
        ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    logseq-sync = {
      Unit = {
        Description = "Logseq sync service";
      };
      Service = {
        ExecStart ="${pkgs.nix}/bin/nix-shell -p git inotify-tools --command ${config.home.homeDirectory}/.config/scripts/logseq-sync-service.sh";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    home-manager-sync = {
      Unit = {
        Description = "Home-manager/config sync service";
      };
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.config/scripts/home-manager-sync-service.sh";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  screen-setup = {
      Unit = {
        Description = "Screen setup";
      };
      Service = {
        ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.screenlayout/default.sh";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
  };
  };
  systemd.user.systemctlPath = "/usr/bin/systemctl";
  systemd.user.sessionVariables = config.home.sessionVariables;
  qt.enable = true;
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
