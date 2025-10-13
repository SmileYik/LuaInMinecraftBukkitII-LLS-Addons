---@meta
---未监听的事件类型.
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.LuaUnregisteredListener: java.lang.Object
---@field private luaEnv org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.ILuaEnv 
---@field private listener org.bukkit.event.Listener 
local LuaUnregisteredListener = {}

---注册Bukkit事件, 需要提供事件监听器名, 并且需要确保在同一个LuaState环境中,所有注册的事件的事件监听器名都必须唯一(没有重复的事件监听器名). 并且后续可以通过事件监听器名去取消监听已注册的事件.
---@public
---@param eventName string 事件监听器名.
---@return nil 
function LuaUnregisteredListener:register(eventName) end

return LuaUnregisteredListener