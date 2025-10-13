---@meta
---这是 Lua 事件的基类
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.event.LuaEvent: java.lang.Object, org.bukkit.event.Event
---@field private HANDLER_LIST org.bukkit.event.HandlerList [STATIC] 
---@field private envName string 
local LuaEvent = {}

---@public
---@return org.bukkit.event.HandlerList 
function LuaEvent:getHandlers() end

return LuaEvent