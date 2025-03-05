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
      vimdiffAlias = mkOption {
        type = with types; bool;
        default = true;
      };
      defaultEditor = mkOption {
        type = with types; bool;
        default = true;
      };
    };
    config = mkIf cfg.enable {
      home.sessionVariables = {EDITOR = "nvim";};

      home.packages = [cfg.package];

      programs.bash.shellAliases = mkIf cfg.vimdiffAlias {vimdiff = "nvim -d";};
      programs.fish.shellAliases = mkIf cfg.vimdiffAlias {vimdiff = "nvim -d";};
      programs.zsh.shellAliases = mkIf cfg.vimdiffAlias {vimdiff = "nvim -d";};

      # Disable home-manager's Neovim
      programs.neovim.enable = mkForce false;
    };
  }
