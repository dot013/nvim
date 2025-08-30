{self}: {
  config,
  lib,
  pkgs,
  ...
}: let
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
        default = self.packages.${pkgs.system}.default;
        readOnly = true;
      };
      defaultEditor = mkOption {
        type = with types; bool;
        default = true;
      };
    };
    config = mkIf cfg.enable {
      environment.variables = {
        EDITOR = "nvim";
      };
      environment.systemPackages = [cfg.package];

      # Disable NixOS's Neovim
      programs.neovim.enable = mkForce false;
    };
  }
