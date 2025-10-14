---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandBuilder: java.lang.Object
local ILuaCommandBuilder = {}

---指令所需要的参数, 这里的参数用于匹配指令长度, 并且给予执行指令人员提示.例如这个指令: <code>/myCommand kill [player_name]</code>, <code>kill</code>是指令名称, 而<code>player_name</code>是一个由执行者提供的参数.所以构建这个指令时, 需要使用这个方法去声明需要提供的参数.对于该例子来说, 可以这样实现:<pre><code>    luaBukkit.env:commandClassBuilder()        :command("kill")            :args({"player_name"})            :handler(function (sender, args) doSomeThing() end)        :build("myCommand")</code></pre>
---@public
---@param ... string|string[] 指令参数
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandBuilder 构造器
function ILuaCommandBuilder:args(...) end

---添加对该指令的简单描述.
---@public
---@param description string 描述
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandBuilder 构造器
function ILuaCommandBuilder:desc(description) end

---添加对该指令的简单描述.
---@public
---@param description string 描述
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandBuilder 构造器
function ILuaCommandBuilder:description(description) end

---添加使用该指令时的权限校验.
---@public
---@param permission string 权限
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandBuilder 构造器
function ILuaCommandBuilder:permission(permission) end

---设定这个指令只能玩家执行.
---@public
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandBuilder 构造器
function ILuaCommandBuilder:needPlayer() end

---设定这个指令的参数为无限长度, 匹配这个指令时会无视args中的实际长度.这在设定一些含空格的参数时特别有效.
---@public
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandBuilder 构造器
function ILuaCommandBuilder:unlimitedArgs() end

---设置这个指令的处理器并完成该指令构造.
---@public
---@param callable function lua闭包
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 指令类构造器
function ILuaCommandBuilder:handler(callable) end

return ILuaCommandBuilder