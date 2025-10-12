---@meta luaBukkit

---@class luaBukkit
---@field public env any The current Lua environment, which can be used to register Bukkit events or commands. 
---@field public helper any Some utility methods for quickly creating Bukkit threads or converting a LuaTable to a Java array.
---@field public io any Utility methods related to I/O streams.
---@field public bukkit any The Bukkit class.
---@field public plugin any The JavaPlugin type instance of the LuaInMinecraftBukkit II plugin.
---@field public server any The CraftServer instance.
---@field public log any The log printer for the current LuaInMinecraftBukkit II plugin.
---@field public out any The System.out standard output stream.
local luaBukkit = {}

return luaBukkit