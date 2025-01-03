{
  symlinkJoin,
  makeWrapper,
  runCommandLocal,
  pkgs,
  lib,
  ...
} @ args: let
  nvimPkg = pkgs.neovim-unwrapped;

  startPlugins = with pkgs;
  with vimPlugins; [
    blink-cmp
    catppuccin-nvim
    indent-blankline-nvim
    lze
    nvim-lspconfig
    nvim-treesitter.withAllGrammars
    nvim-treesitter-textobjects
    nvim-treesitter-textsubjects

    (vimUtils.buildVimPlugin {
      name = "dot013.nvim";
      src = ./.;
    })
  ];

  optPlugins = with pkgs;
  with pkgs.vimPlugins; [
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
    nvim-ts-autotag
    nvim-web-devicons
    telescope-nvim
    telescope-fzf-native-nvim
    trouble-nvim
    tmux-nvim
    vim-sleuth

    (vimUtils.buildVimPlugin {
      pname = "nvim-emmet";
      version = "v0.4.4";
      src = fetchGit {
        url = "https://github.com/olrtg/nvim-emmet";
        rev = "cde4fb2968704aae5c18b7f8a9bc2508767bb78d";
      };
    })

    # Probably can be replaced by local functions in the config
    (vimUtils.buildVimPlugin {
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
    lua-language-server
    nil
    tailwindcss-language-server
    typescript-language-server
    rust-analyzer
    vscode-langservers-extracted

    # Temporally solution since there isn't a easy way to install pnpm packages
    (pkgs.writeShellScriptBin "unocss-language-server" ''
      ${lib.getExe pkgs.bun} x unocss-language-server@0.1.5 "$@"
    '')
  ];

  formatters = with pkgs; [
    alejandra
    shellharden
    shfmt
    jq
  ];

  packages = with pkgs; [
    lf
    ripgrep

    args.go-grip
    args.yazi
  ];

  foldPlugins = builtins.foldl' (acc: next: acc ++ [next] ++ (foldPlugins (next.dependencies or []))) [];

  startPluginsWithDeps = lib.unique (foldPlugins startPlugins);
  optPluginsWithDeps = lib.unique (foldPlugins optPlugins);

  packpath = let
    packageName = "dot013";
  in
    runCommandLocal "packpath" {} ''
      mkdir -p $out/pack/${packageName}/{start,opt}

      ${lib.concatMapStringsSep "\n"
        (plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/start/${lib.getName plugin}")
        startPluginsWithDeps}

      ${lib.concatMapStringsSep "\n"
        (plugin: "ln -vsfT ${plugin} $out/pack/${packageName}/opt/${lib.getName plugin}")
        optPluginsWithDeps}
    '';

  initLua = let
    luaPackages = lp: [];
    luaEnv = nvimPkg.lua.withPackages luaPackages;
    inherit (nvimPkg.lua.pkgs.luaLib) genLuaPathAbsStr genLuaCPathAbsStr;
  in
    pkgs.writeText "init.lua" ''
      -- Don't use LUA_PATH and LUA_CPATH, since they leak into the LSP
      package.path = "${genLuaPathAbsStr luaEnv};" .. package.path
      package.cpath = "${genLuaCPathAbsStr luaEnv};" .. package.cpath

      -- No remote plugins
      vim.g.loaded_node_provider = 0
      vim.g.loaded_perl_provider = 0
      vim.g.loaded_python_provider = 0
      vim.g.loaded_python3_provider = 0
      vim.g.loaded_ruby_provider = 0

      require("dot013")
    '';

  nvim-derivation = symlinkJoin {
    name = "neovim-custom";
    pname = "nvim";

    paths = let
      wrappedNvim = pkgs.writeShellScriptBin "nvim" ''
        export PATH=${lib.makeBinPath (languageServers ++ formatters ++ packages)}:$PATH
        ${lib.getExe nvimPkg} "$@"
      '';
    in [wrappedNvim];

    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      wrapProgram $out/bin/nvim \
        --add-flags '-u' \
        --add-flags '${initLua}' \
        --add-flags '--cmd' \
        --add-flags "'set packpath^=${packpath} | set runtimepath^=${packpath}'" \
        --set-default NVIM_APPNAME nvim-custom
    '';

    passthru = {
      inherit packpath;
    };

    meta = {
      mainProgram = "nvim";
    };
  };
in
  pkgs.stdenv.mkDerivation rec {
    name = "Neovim";
    pname = "nvim";
    buildCommand = let
      desktopEntry = pkgs.makeDesktopItem {
        name = pname;
        desktopName = name;
        exec = "${lib.getExe nvim-derivation}";
        terminal = true;
      };
    in ''
      mkdir -p $out/bin
      cp ${lib.getExe nvim-derivation} $out/bin
      mkdir -p $out/share/applications
      cp ${desktopEntry}/share/applications/${pname}.desktop $out/share/applications/${pname}.desktop
    '';
  }
