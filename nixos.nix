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
      environment.systemPackages = [
        neovim
        (pkgs.writeShellScriptBin "vi" ''${bin} "$@"'')
        (pkgs.writeShellScriptBin "vim" ''${bin} "$@"'')
      ];

      environment.variables.EDITOR = mkDefault "${bin}";
      environment.pathsToLink = ["/share/nvim"];
    })
