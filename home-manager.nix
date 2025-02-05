{
  inputs,
  self,
}: ({
    config,
    pkgs,
    lib,
    ...
  }:
    with lib; let
      neovim = pkgs.callPackage ./neovim.nix {
        go-grip = inputs.go-grip.packages.${pkgs.system}.default;
        yazi = config.programs.yazi.package;
      };
      bin = lib.getExe neovim;
    in {
      home.packages = [
        neovim
      ];

      home.sessionVariables.EDITOR = mkDefault "${bin}";

      programs.bash.shellAliases = {
        vimdiff = mkDefault "${bin} -d";
        vi = mkDefault "${bin}";
        vim = mkDefault "${bin}";
      };
      programs.fish.shellAliases = {
        vimdiff = mkDefault "${bin} -d";
        vi = mkDefault "${bin}";
        vim = mkDefault "${bin}";
      };
      programs.zsh.shellAliases = {
        vimdiff = mkDefault "${bin} -d";
        vi = mkDefault "${bin}";
        vim = mkDefault "${bin}";
      };
    })
