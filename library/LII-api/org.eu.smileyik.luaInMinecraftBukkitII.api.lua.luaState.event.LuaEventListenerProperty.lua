---@meta
---事件监听JavaBean类型.
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.LuaEventListenerProperty: java.lang.Object
---@field private event string 事件类型全类名, 必填.
---@field private priority string 事件优先级, 选填, 默认为<code>NORMAL</code>, 可用值为<code>LOWEST</code>, <code>LOW</code>, <code>NORMAL</code>,<code>HIGH</code>, <code>HIGHEST</code>, <code>MONITOR</code>.并且大小写不敏感.
---@field private ignoreCancelled boolean 是否忽略已经取消的事件. 选填, 默认为false
---@field private handler function 事件处理器, 必填. 该字段为一个Lua闭包, 并且闭包应该拥有一个形参,用于接收事件实例.
local LuaEventListenerProperty = {}

return LuaEventListenerProperty