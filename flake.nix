{
  description = "My development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    go-grip = {
      url = "github:guz013/go-grip";
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
      };
    });
  };
}
