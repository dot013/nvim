{
  pkgs,
  lib,
  neovim ? pkgs.neovim,
  blink-cmp ? pkgs.vimPlugins.blink-cmp,
  ripgrep ? pkgs.ripgrep,
  mdfmt ? null,
  go-grip ? null,
  yazi ? pkgs.yazi,
  ...
}: let
  start =
    (with pkgs.vimPlugins; [
      catppuccin-nvim
      indent-blankline-nvim
      lze
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      nvim-treesitter-textsubjects

      (
        (pkgs.vimUtils.buildVimPlugin {
          name = "dot013.nvim";
          src = ./.;
        }).overrideAttrs
        {doCheck = false;}
      )
    ])
    ++ [
      blink-cmp
    ];
  opt = with pkgs.vimPlugins; [
    auto-save-nvim
    auto-session
    cloak-nvim
    conform-nvim
    comment-nvim
    friendly-snippets
    gitsigns-nvim
    harpoon2
    lualine-nvim
    luasnip
    marks-nvim
    nvim-autopairs
    nvim-dap
    nvim-dap-go
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-nio
    nvim-ts-autotag
    nvim-web-devicons
    tailwind-tools-nvim
    telescope-nvim
    telescope-zf-native-nvim
    telescope-undo-nvim
    trouble-nvim
    tmux-nvim
    vim-sleuth

    (pkgs.vimUtils.buildVimPlugin {
      pname = "aw-watcher.nvim";
      version = "master";
      src = fetchGit {
        url = "https://github.com/lowitea/aw-watcher.nvim";
        rev = "be7b03748f59b6602502baf08e7f7736cc7279a5";
      };
    })

    (pkgs.vimUtils.buildVimPlugin {
      pname = "nvim-emmet";
      version = "v0.4.4";
      src = fetchGit {
        url = "https://github.com/olrtg/nvim-emmet";
        rev = "cde4fb2968704aae5c18b7f8a9bc2508767bb78d";
      };
    })

    # Probably can be replaced by local functions in the config
    (pkgs.vimUtils.buildVimPlugin {
      pname = "tfm.nvim";
      version = "2024-04-23";
      src = fetchGit {
        url = "https://github.com/Rolv-Apneseth/tfm.nvim";
        rev = "fb0de2c96bf303216ac5d91ce9bdb7f430030f8b";
      };
    })
  ];

  languageServers = with pkgs; [
    emmet-language-server
    deno
    gopls
    golangci-lint-langserver
    htmx-lsp
    lemminx
    lua-language-server
    nil
    marksman
    tailwindcss-language-server
    typescript-language-server
    rust-analyzer
    vscode-langservers-extracted
  ];

  formatters = with pkgs; [
    alejandra
    jq
    html-tidy
    libxml2
    mdfmt
    prettierd
    shellharden
    shfmt
  ];

  externalDependencies = [
    ripgrep
    go-grip
    yazi
  ];
in
  neovim.override {
    viAlias = true;
    vimAlias = true;
    configure.packages.plugins = {inherit start opt;};
    extraMakeWrapperArgs = let
      binPath = lib.makeBinPath (languageServers ++ formatters ++ externalDependencies);
    in "--suffix PATH : ${binPath}";
  }
