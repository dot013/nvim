{
  pkgs,
  lib,
  neovim ? pkgs.neovim,
  mdfmt ? null,
  yazi ? pkgs.yazi,
  godotdev ? (pkgs.vimUtils.buildVimPlugin {
    pname = "godotdev.nvim";
    version = "v0.2.3";
    src = fetchGit {
      url = "https://github.com/Mathijs-Bakker/godotdev.nvim";
      rev = "79d9315988b7772c03a1cabb6f31f5287c849e2b";
    };
  }),
  ...
}: let
  dot-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "dot.nvim";
    src = lib.cleanSource ./.;
  };
in
  neovim.override {
    viAlias = true;
    vimAlias = true;
    configure.packages.plugins = {
      # Reference: ./lua/dot/plugins.lua

      start = with pkgs.vimPlugins; [
        lze
        lzextras

        # Language Server Protocol
        nvim-lspconfig

        # Autocomplete
        blink-cmp
        friendly-snippets # Snippets

        # Treesitter (Syntax Highlighting)
        nvim-treesitter
        # nvim-treesitter-textobjects # Dependency
        # nvim-treesitter-textsubjects # Dependency

        (dot-nvim.overrideAttrs {doCheck = false;})
      ];
      opt = with pkgs.vimPlugins; [
        # Language Server Protocol
        lazydev-nvim

        # Debugger
        nvim-dap
        nvim-dap-ui
        nvim-nio # Dependency

        # Formatting
        conform-nvim
        guess-indent-nvim

        # Auto Complete
        nvim-autopairs

        # Fuzzy Finding
        telescope-nvim
        telescope-zf-native-nvim # Dependency

        # Quick file switching
        harpoon2

        # Auto saving
        auto-save-nvim

        # Session restore
        auto-session

        # Secrets hiding
        cloak-nvim

        # Taks Management
        overseer-nvim

        # Appearance
        catppuccin-nvim
        indent-blankline-nvim

        # Git
        gitsigns-nvim

        # Todo Comments
        todo-comments-nvim

        # Obsidian Integration
        obsidian-nvim

        # Integrations
        (pkgs.vimUtils.buildVimPlugin {
          pname = "aw-watcher.nvim";
          version = "master";
          src = fetchGit {
            url = "https://github.com/lowitea/aw-watcher.nvim";
            rev = "be7b03748f59b6602502baf08e7f7736cc7279a5";
          };
        })
        godotdev
      ];
      # inherit start opt;
    };
    extraMakeWrapperArgs = let
      binPath = lib.makeBinPath (with pkgs;
        [
          # INFO: LSP Providers
          # Reference: ./lua/dot/lsp.lua

          vscode-langservers-extracted # cssls, eslint, html, jsonls, typescript

          clang-tools
          docker-language-server
          emmet-language-server
          golangci-lint-langserver
          gopls
          htmx-lsp
          lemminx
          lua-language-server
          marksman
          nil
          rust-analyzer
          tailwindcss-language-server
          typescript-language-server
        ]
        ++ [
          # INFO: Formatters
          # Reference: ./lua/dot/formatting.lua

          # TODO: Remove some formatters from Neovim's path and let them be provided
          # by flake.nix in projects

          alejandra
          gdtoolkit_4
          html-tidy
          jq
          libxml2
          mdfmt
          prettierd
          shellharden
          shfmt
        ]
        ++ [
          # INFO: External dependencies

          go-grip # Reference: ./lua/dot/commands.lua#Grip markdown reader
          ripgrep # Reference ./lua/dot/plugins.lua#telescope.nvim
          yazi # Reference ./lua/dot/commands.lua#Yazi file manager
          zf # Reference ./lua/dot/plugins.lua#telescope-zf-native.nvim
          wl-clipboard # Reference ./lua/dot/plugins.lua#obsidian.nvim
        ]);
    in "--suffix PATH : ${binPath}";
  }
