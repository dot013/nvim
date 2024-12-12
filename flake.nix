{
  description = "My development environment";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    go-grip = {
      url = "github:guz013/go-grip";
    };
    yazi = {
      url = "github:sxyazi/yazi";
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
        yazi = inputs.yazi.packages.${system}.default;
      };
      default = self.packages.${system}.neovim;
    });

    legacyPackages = self.packages;

    nixosModules = {
      neovim = {pkgs, ...}: {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          viAlias = true;
          package = self.packages.${pkgs.system}.neovim;
        };
      };
      default = self.nixosModules.neovim;
    };

    homeManagerModules = {
      neovim = {pkgs, ...}: {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          viAlias = true;
          vimdiffAlias = true;
          package = self.packages.${pkgs.system}.neovim;
        };
      };
      default = self.homeManagerModules.neovim;
    };
    homeManagerModule = self.homeManagerModules;

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
