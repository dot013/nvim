{
  description = "My development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system: let
        pkgs = import nixpkgs {inherit system overlays;};
      in
        f system pkgs);

    grip = {
      pkgs,
      lib,
    }: let
      gripConf = pkgs.writeText "settings.py" ''
        HOST = "0.0.0.0"
      '';
      gripHome = pkgs.stdenv.mkDerivation {
        name = "grip-conf";
        src = gripConf;
        phases = ["installPhase"];
        installPhase = ''
          mkdir -p $out
          cp $src $out/settings.py
        '';
      };
    in
      pkgs.writeShellScriptBin "grip" ''
        export GRIPHOME="${gripHome}"
          ${lib.getExe pkgs.python312Packages.grip} "$@"
      '';
  in {
    packages = forAllSystems (system: pkgs: {
      grip = pkgs.callPackage grip {};
      neovim = pkgs.callPackage ./neovim.nix {inherit self;};
      default = self.packages.${system}.neovim;
    });

    devShells = forAllSystems (system: pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          stylua
        ];
      };
    });
  };
}
