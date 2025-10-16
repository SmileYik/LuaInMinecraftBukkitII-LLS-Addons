# LuaInMinecraftBukkitII-LLS-Addon

This repository aims to add [LuaInMinecraftBukkitII] API for the [Lua Language Server]. Cloned template from [LuaLS-addon-template][lls-addon-template]

**This [Lua Language Server] addon include plugin.**

## Feature

* Capture `luajava.bindClass` / `luajava.createProxy` / `luajava.newInstance` function and mark the return type.
* Capture `luajava.new` function and trace type.
* Capture Bukkit event handlers and annotate event handler parameter types
* Capture Bukkit command handlers and annotate the command handler parameter types

## How to use

At first you need download this repository, if you installed git, you can simply use `git clone https://github.com/SmileYik/LuaInMinecraftBukkitII-LLS-Addon` to clone this repository.

Then, install [Lua Language Server][LuaLS-Install] plugin in your editor, the editor could be Vim, [Visual Studio Code][VSCodeInstall] or [VSCodium][VSCodiumInstall].

Finally, [config Lua Language Server][LuaLS-Config], make sure you add addon path `/path/to/your/LuaInMinecraftBukkitII-LLS-Addon` to `Lua.workspace.library` and add plugin file `/path/to/your/LuaInMinecraftBukkitII-LLS-Addon/plugin.lua` to `Lua.runtime.plugin`.

If you use [Visual Studio Code][VSCodeInstall] or [VSCodium][VSCodiumInstall], you can simply add file `/path/to/your/project/.vscode/settings.json`, and then write the config like:

```json
{
    "Lua.runtime.plugin": "/path/to/LuaInMinecraftBukkitII-LLS-Addon/plugin.lua",
    "Lua.workspace.library": [
        "/path/to/LuaInMinecraftBukkitII-LLS-Addon/"
    ]
}
```

There also have a [vscode project template][vscode-project-template]

## Example

![pic-example]

[LuaInMinecraftBukkitII]: https://github.com/SmileYik/LuaInMinecraftBukkitII
[Lua Language Server]: https://luals.github.io/
[lls-addon-template]: https://github.com/LuaLS/addon-template
[LuaLS-Install]: https://luals.github.io/#install
[VSCodeInstall]: https://code.visualstudio.com/
[VSCodiumInstall]: https://vscodium.com/
[LuaLS-Config]: https://luals.github.io/wiki/configuration/
[vscode-project-template]: ./templates/vscode-template
[pic-example]: ./docs/example.png
