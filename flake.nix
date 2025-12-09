{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    mdfmt = {
      url = "github:moorereason/mdfmt";
      flake = false;
    };
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
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (
        system: let
          pkgs = import nixpkgs {inherit system;};
        in
          f {
            inherit pkgs;
            inherit (pkgs) lib stdenv;
          }
      );
  in {
    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);

    packages = forAllSystems (
      {
        pkgs,
        lib,
        stdenv,
        ...
      }: {
        neovim = pkgs.callPackage ./package.nix {
          mdfmt = self.packages.${stdenv.hostPlatform.system}.mdfmt;
        };
        mdfmt = pkgs.buildGoModule {
          name = "mdfmt";
          src = inputs.mdfmt;
          vendorHash = "sha256-JtYvDgjUoEc1Mp7Eq8lbu9jWI+RR9yBo4ujGY+J70J4=";
        };
        default = self.packages."${stdenv.hostPlatform.system}".neovim;
      }
    );
    devShells = forAllSystems (
      {pkgs, ...}: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            stylua
          ];
        };
      }
    );

    nixosModules = {
      neovim = import ./nixos.nix {inherit self;};
      default = self.nixosModules.neovim;
    };
    homeManagerModules = {
      neovim = import ./home.nix {inherit self;};
      default = self.homeManagerModules.neovim;
    };
  };
}
