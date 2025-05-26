{
  description = "My Neovim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    blink-cmp = {
      url = "github:Saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    go-grip = {
      url = "github:guz013/go-grip";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      nixpkgs.lib.genAttrs systems (system: let
        pkgs = import nixpkgs {inherit system;};
      in
        f {
          inherit pkgs;
          inherit (pkgs) lib;
        });
  in {
    packages = forAllSystems ({
      pkgs,
      lib,
      ...
    }: {
      neovim = import ./package.nix {
        inherit pkgs lib;
        blink-cmp = inputs.blink-cmp.packages.${pkgs.system}.default;
        go-grip = inputs.go-grip.packages.${pkgs.system}.default;
        mdfmt = self.packages.${pkgs.system}.mdfmt;
      };
      mdfmt = pkgs.buildGoModule {
        name = "mdfmt";
        src = inputs.mdfmt;
        vendorHash = "sha256-JtYvDgjUoEc1Mp7Eq8lbu9jWI+RR9yBo4ujGY+J70J4=";
      };
      default = self.packages."${pkgs.system}".neovim;
    });
    devShells = forAllSystems ({pkgs, ...}: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          stylua
        ];
      };
    });

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
