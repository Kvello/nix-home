{ config, pkgs,lib, ... }:
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
    pkgs.python312  # or pkgs.python310, pkgs.python38, etc.
    pyenv
    # Install pip if not included by default
    pkgs.python312Packages.pip  # Adjust for the Python version chosen

    # Some commonly used Python packages
    pkgs.python312Packages.virtualenv  # For creating isolated environments
    pkgs.python312Packages.flake8      # For linting
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
  home.file.".config/Code/User/settings.json" = {
    text = ''
    {
      "workbench.colorTheme": "Gruvbox Dark Soft",  # Replace with the correct theme name

      // Font configuration
      "editor.fontFamily": "JetBrains Mono, Consolas, 'Courier New', monospace",
      "editor.fontSize": 14,
      "editor.fontWeight": "normal",
      "editor.lineHeight": 22,
      "editor.letterSpacing": 0.5,
    }
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
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      pkgs.vscode-extensions.ms-python.python
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.njpwerner.autodocstring
      pkgs.vscode-extensions.github.copilot
      pkgs.vscode-extensions.github.copilot-chat
      pkgs.vscode-extensions.jdinhlife.gruvbox
    ];
  };
  programs.spotify-player = {
    enable = true;
  };
  programs.pyenv = {
    enable = true;
    programs.pyenv.enableBashIntegration = true;
    programs.pyenv.enableFishIntegration = true;
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
