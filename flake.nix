{
  description = "My development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    go-grip = {
      url = "github:guz013/go-grip";
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
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system: let
        pkgs = import nixpkgs {inherit system overlays;};
      in
        f system pkgs);
  in {
    packages = forAllSystems (system: pkgs: {
      neovim = pkgs.callPackage ./neovim.nix {
        go-grip = inputs.go-grip.packages.${system}.default;
      };
      default = self.packages.${system}.neovim;
    });

    legacyPackages = self.packages;

    nixosModules = {
      neovim = (import ./home-manager.nix) {inherit inputs self;};
      default = self.nixosModules.neovim;
    };

    homeManagerModules = {
      neovim = (import ./home-manager.nix) {inherit inputs self;};
      default = self.homeManagerModules.neovim;
    };

    devShells = forAllSystems (system: pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          alejandra
          stylua
        ];
      };
    });
  };
}
