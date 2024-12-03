{
  symlinkJoin,
makeWrapper,
runCommandLocal,
pkgs,
lib,
}: let
  nvimPkg = pkgs.neovim-unwrapped;

  startPlugins = with pkgs; with vimPlugins; [
    lze
    (vimUtils.buildVimPlugin {
      name = "dot013.nvim";
      src = ./.;
    })
  ];

  optPlugins = with pkgs; with pkgs.vimPlugins; [
    telescope-nvim
    telescope-fzf-native-nvim
    nvim-treesitter.withAllGrammars
  ];

  foldPlugins = builtins.foldl' (acc: next: acc ++ [ next ] ++ (foldPlugins (next.dependencies or []))) [];

  startPluginsWithDeps = lib.unique (foldPlugins startPlugins);
  optPluginsWithDeps = lib.unique (foldPlugins optPlugins);

  packpath = let
   packageName = "dot013";
  in  runCommandLocal "packpath" {} ''
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
  in  pkgs.writeText "init.lua" ''
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
in symlinkJoin {
  name = "neovim-custom";
  pname = "nvim";

  paths = [nvimPkg];
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
