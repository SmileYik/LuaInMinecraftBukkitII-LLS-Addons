---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.luaState.ILuaStateEnv: java.lang.Object
local ILuaStateEnv = {}

---@public
---@return boolean 
function ILuaStateEnv:isInitialized() end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function ILuaStateEnv:evalFile(file) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function ILuaStateEnv:evalLua(luaScript) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function ILuaStateEnv:callClosure(globalClosureName, ...) end

---@public
---@return org.eu.smileyik.luaInMinecraftBukkitII.luaState.luacage.ILuacage 
function ILuaStateEnv:getLuacage() end

return ILuaStateEnv