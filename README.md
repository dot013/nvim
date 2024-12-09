
# Neovim

Minimal Neovim configuration, focused mostly in just coding and text editing.

## Features

- Wrapped `nvim` binary to bundle the Lua configuration (no need to use `~/.config/nvim`);
- Plugin management done via [Nix](https://nixos.org), with lazy-loading handled by [`lze`](https://github.com/BirdeeHub/lze/);
- File management done via [`lf`](https://github.com/gokcehan/lf);
- Configured Language Server Protocol (LSP) support, with all used LSPs bundled with the binary;
- Auto-formatting on save.

### To-Do

- [ ] Move [`go-grip`](https://github.com/chrishrb/go-grip) integration to it's own plugin
  (similar to [`peek.nvim`](https://github.com/toppair/peek.nvim));
- [ ] Test configuration as a Neovim plugin;
- [x] Use [Yazi](https://github.com/sxyazi/yazi) instead of `lf` as file manager;
- [ ] Bundle and use default formatters for when no one is available on `PATH`;
- [ ] Better stylize the editor (mainly pop-overs and hover menus).


## Using

The configuration is mainly intended to be used with the Nix package manager. However,
due to the structured of this configuration, it may be possible to use it as a plugin.

### Nix

If you have Nix installed (with [Flakes](https://wiki.nixos.org/wiki/Flakes) enabled),
you can run the configured Neovim binary with just:

```sh
nix run git+https://forge.capytal.company/dot013/nvim

# GitHub mirror
niix run github:dot013/nvim
```

It also can be used as a NixOS or [Home-Manager](https://github.com/nix-community/home-manager)
module:

```nix
# flake.nix
{
    inputs = {
        dot013-neovim.url = "git+https://forge.capytal.company/dot013/nvim"
    };
    outputs = { ... } @ inputs: {
        # your NixOS configurations ...
    };
}
```
```nix
# configuration.nix
{ inputs, ... }: {
    imports = [
        inputs.dot013-neovim.nixosModules.nvim
    ];
}
```
```nix
# home.nix
{ inputs, ... }: {
    imports = [
        inputs.dot013-neovim.homeManagerModules.nvim
    ];
}
```

### Neovim Plugin

All the configuration is provided under the plugin/Lua namespace "`dot013`", so it may be possible
to install it on a conventional `~/.config/nvim` Lua config. **This is not tested or even
planned to be supported**, and all dependencies would need to be handled manually in one
way or another compatible with `lze`'s plugin loading (with is simply based on Neovim's default
plugin loading).

## Acknowledgments

This configuration was a learning experience, both on how to wrap programs using Nix and
to better understand NeoVim and it's APIs. I (@Guz013) wouldn't be able to make this config
without the help and inspiration from:

- Fernando Ayats' blog post on creating a [Neovim wrapper with Nix from scratch](https://ayats.org/blog/neovim-wrapper);
- Inspirations from [`peek.nvim`](https://github.com/toppair/peek.nvim)'s source-code to be able to
  run CLI applications with the Neovim API;
- Christoph's [`go-grip`](https://github.com/chrishrb/go-grip), used as the
  Markdown previewer webserver.

## License

Copyright &copy; 2024-present Gustavo "Guz" L. de Mello <contact@guz.one>

This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
the [LICENSE](./LICENSE) file or http://www.wtfpl.net/ for more details.

> A mirror of this program is also available on https://github.com/dot013/nvim


