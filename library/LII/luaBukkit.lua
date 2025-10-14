---@meta

---@class luaBukkit
---@field public env org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.ILuaEnv The current Lua environment, which can be used to register Bukkit events or commands. 
---@field public helper org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.LuaHelper Some utility methods for quickly creating Bukkit threads or converting a LuaTable to a Java array.
---@field public io org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.LuaIOHelper Utility methods related to I/O streams.
---@field public bukkit org.bukkit.Bukkit The Bukkit class.
---@field public plugin org.bukkit.plugin.Plugin The JavaPlugin type instance of the LuaInMinecraftBukkit II plugin.
---@field public server org.bukkit.Server The CraftServer instance.
---@field public log java.util.logging.Logger The log printer for the current LuaInMinecraftBukkit II plugin.
---@field public out java.io.PrintStream The System.out standard output stream.
local luaBukkit = {}

return luaBukkit