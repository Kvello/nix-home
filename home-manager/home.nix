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
  customOverlay = final: prev: {
    mesa = prev.mesa.overrideAttrs (oldAttrs: rec {
      # Adding meson flags
      mesonFlags = oldAttrs.mesonFlags ++ [
        "-D vulkan-layers=device-select,overlay"
      ];
    });
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
  home.stateVersion = "25.05"; # Please read the comment before changing.
  home.language = {
    base = "en_US.UTF-8";
  };
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    EDITOR = "vim";
  };
  nixpkgs.overlays = [
    # customOverlay
  ];
  home.packages = with pkgs; [
    git
    vim
    wofi
    kitty
    texliveFull
    pyenv
    pywal
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
    spotify
    bitwarden-desktop
    jetbrains-mono
    pkgs.python312
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
    gnuplot
    ganttproject-bin
    zed-editor
    neofetch
    vulkan-tools
    vulkan-validation-layers
    mesa
    pdftk
    gnumake
    (pkgs.nerd-fonts.meslo-lg)
  ];
    fonts.fontconfig = {
      enable = true;
    };

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
  programs.pyenv.enable = true;
  programs.fish = {
    enable = true;
    interactiveShellInit = "
      # Basic colors
      set -U fish_color_command ebdbb2 
      set -U fish_color_error d75f5f

      # Tide prompt color configuration
      set -U tide_character_color afaf00
      set -U tide_character_color_failure d75f5f
      set -U tide_pwd_bg_color 83adad
      set -U tide_git_bg_color ffaf00
      set -U tide_git_color_branch 262626
      set -U tide_git_bg_color_unstable d75f5f
      set -U tide_git_bg_color_urgent d75f5f
      set -U tide_os_bg_color ebdbb2
      set -U tide_pwd_color_dirs ebdbb2
      set -U tide_pwd_color_anchors ebdbb2

      # Tide prompt configuration
      set -U tide_left_prompt_separator_diff_color 
      set -U tide_left_prompt_separator_same_color 
      set -U tide_left_prompt_items os pwd git
      set -U tide_left_prompt_frame_enabled true
      set -U tide_left_prompt_prefix 
      set -U tide_pwd_icon 
      set -U tide_nix_shell_icon 
      set -U tide_pwd_icon_home 
      set -U tide_pwd_icon_unwritable 
      set -U tide_left_prompt_suffix 
      set -U tide_prompt_pad_items true


      set -U tide_aws_bg_color FF9900
      set -U tide_aws_color 232F3E
      set -U tide_aws_icon 
      set -U tide_character_color afaf00
      set -U tide_character_color_failure d75f5f
      set -U tide_character_icon ❯
      set -U tide_character_vi_icon_default ❮
      set -U tide_character_vi_icon_replace ▶
      set -U tide_character_vi_icon_visual V
      set -U tide_cmd_duration_bg_color C4A000
      set -U tide_cmd_duration_color 000000
      set -U tide_cmd_duration_decimals 0
      set -U tide_cmd_duration_icon 
      set -U tide_cmd_duration_threshold 3000
      set -U tide_context_always_display false
      set -U tide_context_bg_color 444444
      set -U tide_context_color_default D7AF87
      set -U tide_context_color_root D7AF00
      set -U tide_context_color_ssh D7AF87
      set -U tide_context_hostname_parts 1
      set -U tide_crystal_bg_color FFFFFF
      set -U tide_crystal_color 000000
      set -U tide_crystal_icon 
      set -U tide_direnv_bg_color D7AF00
      set -U tide_direnv_bg_color_denied FF0000
      set -U tide_direnv_color 000000
      set -U tide_direnv_color_denied 000000
      set -U tide_direnv_icon ▼
      set -U tide_distrobox_bg_color FF00FF
      set -U tide_distrobox_color 000000
      set -U tide_distrobox_icon 󰆧
      set -U tide_docker_bg_color 2496ED
      set -U tide_docker_color 000000
      set -U tide_docker_default_contexts 'default'  'colima'
      set -U tide_docker_icon 
      set -U tide_elixir_bg_color 4E2A8E
      set -U tide_elixir_color 000000
      set -U tide_elixir_icon 
      set -U tide_gcloud_bg_color 4285F4
      set -U tide_gcloud_color 000000
      set -U tide_gcloud_icon 󰊭
      set -U tide_git_color_branch 262626
      set -U tide_git_color_conflicted 000000
      set -U tide_git_color_dirty 000000
      set -U tide_git_color_operation 000000
      set -U tide_git_color_staged 000000
      set -U tide_git_color_stash 000000
      set -U tide_git_color_untracked 000000
      set -U tide_git_color_upstream 000000
      set -U tide_git_icon 
      set -U tide_git_truncation_length 24
      set -U tide_git_truncation_strategy
      set -U tide_go_bg_color 00ACD7
      set -U tide_go_color 000000
      set -U tide_go_icon 
      set -U tide_java_bg_color ED8B00
      set -U tide_java_color 000000
      set -U tide_java_icon 
      set -U tide_jobs_bg_color 444444
      set -U tide_jobs_color 4E9A06
      set -U tide_jobs_icon 
      set -U tide_jobs_number_threshold 1000
      set -U tide_kubectl_bg_color 326CE5
      set -U tide_kubectl_color 000000
      set -U tide_kubectl_icon 󱃾
      set -U tide_left_prompt_frame_enabled true
      set -U tide_left_prompt_prefix 
      set -U tide_left_prompt_separator_same_color 
      set -U tide_left_prompt_suffix 
      set -U tide_nix_shell_bg_color 7EBAE4
      set -U tide_nix_shell_color 000000
      set -U tide_nix_shell_icon 
      set -U tide_node_bg_color 44883E
      set -U tide_node_color 000000
      set -U tide_node_icon 
      set -U tide_os_bg_color ebdbb2
      set -U tide_os_color E95420
      set -U tide_os_icon 
      set -U tide_php_bg_color 617CBE
      set -U tide_php_color 000000
      set -U tide_php_icon 
      set -U tide_private_mode_bg_color F1F3F4
      set -U tide_private_mode_color 000000
      set -U tide_private_mode_icon 󰗹
      set -U tide_prompt_add_newline_before false
      set -U tide_prompt_color_frame_and_connection 6C6C6C
      set -U tide_prompt_color_separator_same_color 949494
      set -U tide_prompt_icon_connection ' '
      set -U tide_prompt_min_cols 34
      set -U tide_prompt_pad_items true
      set -U tide_prompt_transient_enabled true
      set -U tide_pulumi_bg_color F7BF2A
      set -U tide_pulumi_color 000000
      set -U tide_pulumi_icon 
      set -U tide_pwd_color_dirs ebdbb2
      set -U tide_pwd_color_truncated_dirs BCBCBC
      set -U tide_pwd_icon 
      set -U tide_pwd_icon_home 
      set -U tide_pwd_icon_unwritable 
      set -U tide_pwd_markers '.bzr'  '.citc'  '.git'  '.hg'  '.node-version'  '.python-ve…
      set -U tide_python_bg_color 444444
      set -U tide_python_color 00AFAF
      set -U tide_python_icon 󰌠
      set -U tide_right_prompt_frame_enabled false
      set -U tide_right_prompt_items 'status'  'cmd_duration'  'context'  'jobs'  'direnv'  'node…
      set -U tide_right_prompt_prefix 
      set -U tide_right_prompt_separator_diff_color 
      set -U tide_right_prompt_separator_same_color 
      set -U tide_right_prompt_suffix 
      set -U tide_ruby_bg_color B31209
      set -U tide_ruby_color 000000
      set -U tide_ruby_icon 
      set -U tide_rustc_bg_color F74C00
      set -U tide_rustc_color 000000
      set -U tide_rustc_icon 
      set -U tide_shlvl_bg_color 808000
      set -U tide_shlvl_color 000000
      set -U tide_shlvl_icon 
      set -U tide_shlvl_threshold 1
      set -U tide_status_bg_color 2E3436
      set -U tide_status_bg_color_failure CC0000
      set -U tide_status_color 4E9A06
      set -U tide_status_color_failure FFFF00
      set -U tide_status_icon ✔
      set -U tide_status_icon_failure ✘
      set -U tide_terraform_bg_color 800080
      set -U tide_terraform_color 000000
      set -U tide_terraform_icon 󱁢
      set -U tide_time_bg_color D3D7CF
      set -U tide_time_color 000000
      set -U tide_time_format '%T'
      set -U tide_toolbox_bg_color 613583
      set -U tide_toolbox_color 000000
      set -U tide_toolbox_icon 
      set -U tide_vi_mode_bg_color_default 949494
      set -U tide_vi_mode_bg_color_insert 87AFAF
      set -U tide_vi_mode_bg_color_replace 87AF87
      set -U tide_vi_mode_bg_color_visual FF8700
      set -U tide_vi_mode_color_default 000000
      set -U tide_vi_mode_color_insert 000000
      set -U tide_vi_mode_color_replace 000000
      set -U tide_vi_mode_color_visual 000000
      set -U tide_vi_mode_icon_default D
      set -U tide_vi_mode_icon_insert I
      set -U tide_vi_mode_icon_replace R
      set -U tide_vi_mode_icon_visual V
      set -U tide_zig_bg_color F7A41D
      set -U tide_zig_color 000000
      set -U tide_zig_icon 
      ";
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
    enable = false;
    profiles.default = {
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
        streetsidesoftware.code-spell-checker
      ];
      userSettings = {
        "files.autoSave" =  "onFocusChange";
        "workbench.colorTheme" = "Gruvbox Dark Soft";
        "workbench.iconTheme" = "material-icon-theme";
        "material-icon-theme.files.associations" =  {
      
        };
        "MATLAB.installPath"= "/usr/local/MATLAB/R2024a"; #OBS! Not managed with home-manager(yet)
        "latex-workshop.latex.outDir" = "build";
        "latex-workshop.latex.recipes" = [
          {
            name = "pdflatex";
            tools = [
              "pdflatex"
            ];
          }
          {
            name = "latexmk";
            tools = [
              "latexmk"
            ];
          }
          {
            name = "pdflatex -> biber -> makeglossaries-> ->makeindex->pdflatex x 2";
            tools = [
              "pdflatex"
              "biber"
              "makeglossaries"
              "makeindex"
              "pdflatex"
              "pdflatex"
            ];
          }
        ];
        "latex-workshop.view.pdf.viewer" = "tab";
        "latex-workshop.latex.tools" = [
          {
            name = "latexmk";
            command = "latexmk";
            args = [
              "-synctex=1"
              "-interaction=nonstopmode"
              "-file-line-error"
              "-output-directory=build"
              "-pdf"
              "%DOC%"
            ];
          }
          {
            name = "pdflatex";
            command = "pdflatex";
            args = [
              "-synctex=1"
              "-interaction=nonstopmode"
              "-output-directory=build"
              "-file-line-error"
              "%DOC%"
            ];
          }
          {
            name = "biber";
            command = "biber";
            args = [
              "build/%DOCFILE%"
            ];
          }
          {
            name = "makeglossaries";
            command = "makeglossaries";
            args = [
              "-d"
              "build"
              "%DOCFILE%"
            ];
          }
          {
            name = "makeindex";
            command = "makeindex";
            args = [
              "build/%DOCFILE%.nlo"
              "-s"
              "nomencl.ist"
              "-o"
              "build/%DOCFILE%.nls"
            ];
          }
        ];
        "cSpell.enabledFileTypes" = ["plaintext" "markdown" "latex"];
        "cSpell.language" = "en";
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
  };
  programs.spotify-player = {
    enable = true;
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
