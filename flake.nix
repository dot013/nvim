{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    mdfmt = {
      url = "github:moorereason/mdfmt";
      flake = false;
    };

    godotdev = {
      # url = "github:Mathijs-Bakker/godotdev.nvim";
      url = "git+file:///home/guz/.projects/guz013-godotdev-nvim";
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
          godotdev = self.packages.${pkgs.system}.godotdev;
        };
        godotdev = pkgs.vimUtils.buildVimPlugin {
          pname = "godotdev.nvim";
          version = "v0.2.3";
          src = inputs.godotdev;
        };
        godot-neovim = pkgs.writeShellScriptBin "godot-neovim" (builtins.readFile ./scripts/godot-neovim.sh);
        gh-actions-language-server = pkgs.callPackage ({
          stdenv,
          lib,
          makeBinaryWrapper,
          buildNpmPackage,
          bun,
          nodejs,
          npmHooks,
          ...
        }: let
          pname = "gh-actions-language-server";
          src = fetchGit {
            url = "https://github.com/lttb/gh-actions-language-server";
            rev = "0287d3081d7b74fef88824ca3bd6e9a44323a54d";
          };
          packageJson = lib.importJSON "${src}/package.json";
          version = packageJson.version;
          node_modules = stdenv.mkDerivation {
            inherit src version;
            pname = "${pname}-node_modules";
            nativeBuildInputs = [bun];
            dontConfigure = true;
            buildPhase = ''
              bun install --no-progress --frozen-lockfile
            '';
            installPhase = ''
              mkdir -p $out/node_modules
              cp -R ./node_modules/* $out/node_modules
              ls -la $out/node_modules
            '';
            dontFixup = true;
            dontPathShebangs = true;
            outputHash = "sha256-HfMP9OI07CpiOQw5xkpcRPKPv/MflU1FjtSMOuCkYtg=";
            outputHashAlgo = "sha256";
            outputHashMode = "recursive";
          };
        in
          stdenv.mkDerivation {
            inherit pname src version;
            buildInputs = [bun nodejs];
            nativeBuildInputs = [makeBinaryWrapper];

            dontConfigure = true;

            buildPhase = ''
              runHook preBuild

              ln -s "${node_modules}/node_modules" ./
              bun run build:node

              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall

              mkdir -p $out
              mv ./bin/$pname $out/$pname
              makeBinaryWrapper ${lib.getExe nodejs} $out/bin/$pname \
                --prefix PATH : ${lib.makeBinPath [nodejs]} \
                --add-flags "$out/$pname"

              runHook postInstall
            '';
            # installPhase = ''
            #   runHook preInstall
            #
            #   mkdir -p $out/bin
            #   makeBinaryWrapper ${lib.getExe nodejs} $out/bin/$pname \
            #     --prefix PATH : "${lib.makeBinPath [nodejs]}"
            #     --add-flags "$out/$pname"
            #
            #   runHook postInstall
            # '';
          }) {};
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
            integrations.godot.enable = mkEnableOption "";
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
              ++ (optionals cfg.integrations.godot.enable [
                self.packages."${pkgs.system}".godot-neovim
              ]);

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
            integrations.godot.enable = mkEnableOption "";
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
              ++ (optionals cfg.integrations.godot.enable [
                self.packages."${pkgs.system}".godot-neovim
              ]);

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
