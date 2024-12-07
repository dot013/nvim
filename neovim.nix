{
  symlinkJoin,
  makeWrapper,
  runCommandLocal,
  pkgs,
  lib,
}: let
  nvimPkg = pkgs.neovim-unwrapped;

  startPlugins = with pkgs;
  with vimPlugins; [
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
    blink-cmp
    cloak-nvim
    conform-nvim
    friendly-snippets
    gitsigns-nvim
    harpoon2
    lualine-nvim
    luasnip
    marks-nvim
    nvim-dap
    nvim-dap-go
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-web-devicons
    telescope-nvim
    telescope-fzf-native-nvim
    tmux-nvim
  ];

  languageServers = with pkgs; [
    deno
    gopls
    htmx-lsp
    lua-language-server
    nil
    tailwindcss-language-server
    templ
    typescript-language-server
    rust-analyzer
    vscode-langservers-extracted
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
in
  symlinkJoin {
    name = "neovim-custom";
    pname = "nvim";

    paths = let
      wrappedNvim = pkgs.writeShellScriptBin "nvim" ''
        export PATH=${lib.makeBinPath languageServers}:$PATH
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
  }
