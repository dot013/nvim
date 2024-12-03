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
  }@inputs: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
      ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: let
      pkgs = import nixpkgs {inherit system overlays;};
    in
      f system pkgs);
  in {
    packages = forAllSystems (system: pkgs: {
      neovim = self.packages.${system}.default;
      default = (pkgs.callPackage ./neovim.nix {});
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
