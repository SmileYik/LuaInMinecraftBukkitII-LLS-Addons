---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder: java.lang.Object
local ILuaEventListenerBuilder = {}

---订阅一个事件
---@public
---@param eventClassName string 事件全类名, 常见类名可以忽略包路径
---@param closure function 事件闭包, 固定一个形参, 为监听的事件实例.
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 此构建器
function ILuaEventListenerBuilder:subscribe(eventClassName, closure) end

---订阅一个事件
---@public
---@param eventClassName string 事件全类名, 常见类名可以忽略包路径
---@param eventPriority org.bukkit.event.EventPriority 事件优先级
---@param closure function 事件闭包, 固定一个形参, 为监听的事件实例.
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 此构建器
function ILuaEventListenerBuilder:subscribe(eventClassName, eventPriority, closure) end

---订阅一个事件
---@public
---@param eventClassName string 事件全类名, 常见类名可以忽略包路径
---@param eventPriority string 事件优先级, 包含<code>LOWEST</code> <code>LOW</code> <code>NORMAL</code>                      <code>HIGH</code> <code>HIGHEST</code> <code>MONITOR</code>
---@param closure function 事件闭包, 固定一个形参, 为监听的事件实例.
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 此构建器
function ILuaEventListenerBuilder:subscribe(eventClassName, eventPriority, closure) end

---订阅一个事件
---@public
---@param eventClassName string 事件全类名, 常见类名可以忽略包路径
---@param eventPriority org.bukkit.event.EventPriority 事件优先级
---@param ignoreCancelled boolean 是否忽略已取消的事件.
---@param closure function 事件闭包, 固定一个形参, 为监听的事件实例.
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 此构建器
function ILuaEventListenerBuilder:subscribe(eventClassName, eventPriority, ignoreCancelled, closure) end

---订阅一个事件
---@public
---@param eventClassName string 事件全类名, 常见类名可以忽略包路径
---@param eventPriority string 事件优先级, 包含<code>LOWEST</code> <code>LOW</code> <code>NORMAL</code>                       <code>HIGH</code> <code>HIGHEST</code> <code>MONITOR</code>
---@param ignoreCancelled boolean 是否忽略已取消的事件.
---@param closure function 事件闭包, 固定一个形参, 为监听的事件实例.
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 此构建器
function ILuaEventListenerBuilder:subscribe(eventClassName, eventPriority, ignoreCancelled, closure) end

---订阅一个事件
---@public
---@param eventClassName string 事件全类名, 常见类名可以忽略包路径
---@param ignoreCancelled boolean 是否忽略已取消的事件.
---@param closure function 事件闭包, 固定一个形参, 为监听的事件实例.
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 此构建器
function ILuaEventListenerBuilder:subscribe(eventClassName, ignoreCancelled, closure) end

---订阅一个事件, 传入LuaTable类型, 并且必须包含<code>event</code>和<code>handler</code>字段.<code>event</code>字段为文本类型, 是要订阅的事件的全类名.<code>handler</code>字段为Lua闭包, 并且包含一个形参.
---@public
---@param table table LuaTable
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 此构建器
function ILuaEventListenerBuilder:subscribe(table) end

---与<code>subscribe(LuaTable)</code>类似, 但是是接受一个LuaTable数组(数组风格LuaTable),以批量订阅事件.
---@public
---@param ... table|table[] table组成的数组, 形似与<code>local tables = {{}, {}, {}}</code>
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 此构建器
function ILuaEventListenerBuilder:subscribes(...) end

---构造未监听的事件实例.
---@public
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.LuaUnregisteredListener 未监听的事件实例
function ILuaEventListenerBuilder:build() end

return ILuaEventListenerBuilder