{self}: {
  config,
  lib,
  pkgs,
  ...
}: let
  neovim = self.packages.${pkgs.system}.default;
  cfg = config.neovim;
in
  with lib; {
    options.neovim = {
      enable = mkOption {
        type = with types; bool;
        default = true;
      };
      package = mkOption {
        type = with types; package;
        default = neovim;
      };
      defaultEditor = mkOption {
        type = with types; bool;
        default = true;
      };
    };
    config = mkIf cfg.enable {
      environment.variables = {EDITOR = "nvim";};

      environment.systemPackages = [cfg.package];

      # Disable NixOS's Neovim
      programs.neovim.enable = mkForce false;
    };
  }
