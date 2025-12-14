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
    neovim-pkgs = system: import nixpkgs {inherit system;};
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
          mdfmt = self.packages.${pkgs.system}.mdfmt;
        };
          godot-neovim = pkgs.writeShellApplication {
            name = "godot-neovim";
          };
        mdfmt = pkgs.buildGoModule {
          name = "mdfmt";
          src = inputs.mdfmt;
          vendorHash = "sha256-JtYvDgjUoEc1Mp7Eq8lbu9jWI+RR9yBo4ujGY+J70J4=";
        };

        default = self.packages."${pkgs.system}".neovim;
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
      neovim = {
        config,
        lib,
        pkgs,
        stdenv,
        ...
      }: let
        cfg = config.neovim;
        npkgs = neovim-pkgs pkgs.system;
      in
        with lib; {
          options.neovim = {
            enable = mkOption {
              type = with types; bool;
              default = true;
            };
            package = mkOption {
              type = with types; package;
              default = self.packages.${pkgs.system}.default;
              readOnly = true;
            };
            defaultEditor = mkOption {
              type = with types; bool;
              default = true;
            };
          };
          config = mkIf cfg.enable {
            environment.variables = {
              EDITOR = "nvim";
            };
            environment.systemPackages =
              [
                (npkgs.callPackage ./package.nix {
                    mdfmt = self.packages.${pkgs.system}.mdfmt;
                  }
                  // (optionalAttrs config.programs.yazi.enable {
                    yazi = config.programs.yazi.package;
                  }))
              ]
            # Disable NixOS's Neovim
            programs.neovim.enable = mkForce false;
          };
        };

      default = self.nixosModules.neovim;
    };
    homeManagerModules = {
      neovim = {
        config,
        lib,
        pkgs,
        stdenv,
        ...
      }: let
        cfg = config.neovim;
        npkgs = neovim-pkgs pkgs.system;
      in
        with lib; {
          options.neovim = {
            enable = mkOption {
              type = with types; bool;
              default = true;
            };
            vimdiffAlias = mkOption {
              type = with types; bool;
              default = true;
            };
            defaultEditor = mkOption {
              type = with types; bool;
              default = true;
            };
          };
          config = mkIf cfg.enable {
            home.sessionVariables = {
              EDITOR = "nvim";
            };

            home.packages =
              [
                (npkgs.callPackage ./package.nix {
                    mdfmt = self.packages.${pkgs.system}.mdfmt;
                  }
                  // (optionalAttrs config.programs.yazi.enable {
                    yazi = config.programs.yazi.package;
                  }))
              ]
            programs.bash.shellAliases = mkIf cfg.vimdiffAlias {vimdiff = "nvim -d";};
            programs.fish.shellAliases = mkIf cfg.vimdiffAlias {vimdiff = "nvim -d";};
            programs.zsh.shellAliases = mkIf cfg.vimdiffAlias {vimdiff = "nvim -d";};

            # Disable home-manager's Neovim
            programs.neovim.enable = mkForce false;
          };
        };

      default = self.homeManagerModules.neovim;
    };
  };
}
