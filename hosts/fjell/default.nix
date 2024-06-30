{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      devNodes = "/dev/mapper";
      forceImportRoot = false;
    };
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      kernelModules = [ "amdgpu" ];
      luks.devices = {
        uno = {
          device = "/dev/disk/by-uuid/f3d8e9b9-2645-4c1b-a34c-157502cd6827";
          allowDiscards = true;
        };
        dos = {
          device = "/dev/disk/by-uuid/b7d4c818-1236-4319-b917-96cc7c12e74c";
          allowDiscards = true;
        };
      };
    };
  };

  services.zfs = {
    trim.enable = true;
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      frequent = 8;
      hourly = 24;
      daily = 14;
      weekly = 0;
      monthly = 6;
      flags = "--utc --keep-zero-sized-snapshots --parallel-snapshots";
    };
  };

  networking = {
    hostName = "fjell";
    hostId = "ae329cd2";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Krasnoyarsk";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    earlySetup = true;
    useXkbConfig = true;
    packages = with pkgs; [ spleen ];
    font = "${pkgs.spleen}/share/consolefonts/spleen-16x32.psfu";
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us,ru";
      options = "ctrl:swapcaps,grp:alt_shift_toggle";
    };
  };

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "regn";
  };

  # Fixes automatic login
  # https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  users.users.regn = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  fonts.packages = with pkgs; [
    cascadia-code
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  environment.systemPackages = with pkgs; [
    adw-gtk3
    age
    amberol
    bc
    blackbox-terminal
    btop
    celluloid
    chezmoi
    curl
    dig
    file
    firefox
    git
    gnome.gnome-tweaks
    helix
    jq
    libva-utils
    papirus-icon-theme
    shadowsocks-rust
    traceroute
    transmission-gtk
    tree
    wl-clipboard
    zstd
  ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Configuration version, do not change
  system.stateVersion = "24.05";
}
