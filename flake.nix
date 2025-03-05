{
  description = "My Neovim configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    go-grip = {
      url = "github:guz013/go-grip";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blink-cmp = {
      url = "github:Saghen/blink.cmp";
      inputs.nixpkgs.follows = "nixpkgs";
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
        go-grip = inputs.go-grip.packages.${pkgs.system}.default;
        blink-cmp = inputs.blink-cmp.packages.${pkgs.system}.default;
      };
      default = self.packages."${pkgs.system}".neovim;
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
