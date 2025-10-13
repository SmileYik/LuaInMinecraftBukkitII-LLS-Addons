---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.config.ILuaStateConfig: java.lang.Object
local ILuaStateConfig = {}

---@public
---@return string 
function ILuaStateConfig:getRootDir() end

---@public
---@return boolean 
function ILuaStateConfig:isIgnoreAccessLimit() end

---@public
---@return java.util.Map 
function ILuaStateConfig:getAttributes() end

return ILuaStateConfig