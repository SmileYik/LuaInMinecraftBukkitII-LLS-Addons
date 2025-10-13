---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.ILuaStateManager: java.lang.Object, java.lang.AutoCloseable
local ILuaStateManager = {}

---创建插件用Lua环境. <br/>插件应该自行管理该环境.
---@public
---@param plugin org.bukkit.plugin.Plugin 插件实例
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.luaState.ILuaStatePluginEnv Lua 环境.
function ILuaStateManager:createPluginEnv(plugin) end

---创建插件用Lua环境. <br/>插件应该自行管理该环境.
---@public
---@param plugin org.bukkit.plugin.Plugin 插件实例
---@param ignoreAccessLimit boolean 忽略访问限制.
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.luaState.ILuaStatePluginEnv Lua 环境.
function ILuaStateManager:createPluginEnv(plugin, ignoreAccessLimit) end

---获取 Lua 实例.
---@public
---@param plugin org.bukkit.plugin.Plugin 插件
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.luaState.ILuaStatePluginEnv 如果没有则返回 null
function ILuaStateManager:getPluginEnv(plugin) end

---销毁插件 Lua 环境.
---@public
---@param plugin org.bukkit.plugin.Plugin 插件实例.
---@return nil 
function ILuaStateManager:destroyPluginEnv(plugin) end

---获取 Lua 实例
---@public
---@param id string 实例 Id
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.luaState.ILuaStateEnv Lua 实例
function ILuaStateManager:getEnv(id) end

---@public
---@return java.util.Collection 
function ILuaStateManager:getScriptEnvIds() end

---获取仅允许脚本的 Lua 环境.
---@public
---@return java.util.Collection 
function ILuaStateManager:getScriptEnvs() end

---关闭并释放资源
---@public
---@return nil 
function ILuaStateManager:close() end

---重新加载指定环境中的初始化脚本.
---@public
---@return nil 
function ILuaStateManager:reloadEnvScript(id) end

---重载整体 Lua 环境.
---@public
---@return nil 
function ILuaStateManager:reload(config) end

---预先加载需要的配置
---@public
---@return nil 
function ILuaStateManager:preLoad() end

---环境初始化, 需要在 preLoad 之后进行运行.
---@public
---@return nil 
function ILuaStateManager:initialization() end

---获取插件配置
---@public
---@return org.eu.smileyik.luaInMinecraftBukkitII.config.Config 
function ILuaStateManager:getConfig() end

return ILuaStateManager