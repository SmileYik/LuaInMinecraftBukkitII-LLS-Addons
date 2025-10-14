---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.luaState.ILuaStatePluginEnv: java.lang.Object
local ILuaStatePluginEnv = {}

---是否忽略 Java 中的访问限制.
---@public
---@return boolean 
function ILuaStatePluginEnv:isIgnoreAccessLimit() end

---获取 Lua 实例.
---@public
---@return org.eu.smileyik.luajava.LuaStateFacade 
function ILuaStatePluginEnv:getLua() end

---执行 Lua 脚本.
---@public
---@param luaScript string Lua 脚本.
---@return org.eu.smileyik.luajava.exception.Result 执行结果.
function ILuaStatePluginEnv:evalLua(luaScript) end

---执行全局 Lua 闭包变量.
---@public
---@param globalClosureName string 闭包名
---@param ... any|any[] 参数
---@return org.eu.smileyik.luajava.exception.Result 执行结果.
function ILuaStatePluginEnv:callClosure(globalClosureName, ...) end

return ILuaStatePluginEnv