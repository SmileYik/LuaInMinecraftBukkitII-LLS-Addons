---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.ILuaEnv: java.lang.Object
local ILuaEnv = {}

---注册事件监听器. 如果需要注册监听器请使用 <code>listenerBuilder()</code>.
---@public
---@param name string 监听器名字
---@param listener org.bukkit.event.Listener 监听器
---@return nil 
function ILuaEnv:registerEventListener(name, listener) end

---取消注册事件监听器.
---@public
---@param name string 注册监听器时提供的监听器名, 名字在同一个lua环境中必须不同(唯一).
---@return nil 
function ILuaEnv:unregisterEventListener(name) end

---获取事件监听构造器, 通过此构造器可以构造Bukkit Listener接口实例.<h1>Lua中的使用示例</h1><h2>构建一个 <code>PlayerJoinEvent</code></h2>以下是构建并注册一个单个Bukkit事件监听的例子.该示例将会监听玩家加入服务器事件, 并且在玩家加入服务器时发送玩家 "Hello 玩家名" 消息.并且将此事件注册监听时, 命名为 "MyPlayerJoinEvent" 以方便后续取消监听.<pre><code>    luaBukkit.env:listenerBuilder()        :subscribe("PlayerJoinEvent",            function (event)                event:getPlayer():sendMessage("Hello " .. event:getPlayer():getName())            end        )        :build()        :register("MyPlayerJoinEvent")</code></pre><h2>构建多个事件</h2>在本例子中将会监听玩家进入服务器事件以及离开服务器事件.<pre><code>    luaBukkit.env:listenerBuilder()        :subscribe("PlayerJoinEvent",            function (event)                event:getPlayer():sendMessage("Hello " .. event:getPlayer():getName())            end        )        :subscribe("org.bukkit.event.player.PlayerQuitEvent",            function (event)                luaBukkit.log:info("Someone leaving: " .. event:getQuitMessage())                luaBukkit.env:unregisterEventListener("MyEvents")            end        )        :build()        :register("MyEvents")</code></pre>
---@public
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.event.ILuaEventListenerBuilder 事件监听构造器.
function ILuaEnv:listenerBuilder() end

---一个简易的语法糖用于快速监听事件
---@public
---@param id string 事件ID
---@param event string 要监听的事件全类名
---@param luaCallable function 事件处理器
---@return nil 
function ILuaEnv:onEvent(id, event, luaCallable) end

---一个简易的语法糖用于快速监听事件, 传入LuaTable类型, 并且必须包含<code>event</code>和<code>handler</code>字段.<code>event</code>字段为文本类型, 是要订阅的事件的全类名.<code>handler</code>字段为Lua闭包, 并且包含一个形参.
---@public
---@param id string 事件ID, 可以后续用来注销事件
---@param event table 事件实体
---@return nil 
function ILuaEnv:onEvent(id, event) end

---一个简易的语法糖用于快速监听事件, 与 onEvent 类似, 不过接收的是数组.
---@public
---@param id string 事件ID, 可以后续用来注销事件
---@param events table 事件实体数组.
---@return nil 
function ILuaEnv:onEvents(id, events) end

---获取指令类构造器.
---@public
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 指令类构造器.
function ILuaEnv:commandClassBuilder() end

---注册指令
---@public
---@param rootCommand string 指令名称.
---@param classes table 指令类型.
---@return org.eu.smileyik.luajava.exception.Result 注册结果.
function ILuaEnv:registerCommand(rootCommand, classes) end

---注册一个原始指令, 该指令与 Bukkit 原始指令一致.
---@public
---@param command string 指令名称
---@param callable function 回调闭包, 指令触发时, 将会传输给闭包形参顺序乳如下: sender, command, label, args, 并且该闭包需要返回 true/false
---@return nil 
function ILuaEnv:registerRawCommand(command, callable) end

---注册指令
---@public
---@param rootCommand string 指令名称.
---@param aliases table 指令别名
---@param classes table 指令类型.
---@return org.eu.smileyik.luajava.exception.Result 注册结果.
function ILuaEnv:registerCommand(rootCommand, aliases, classes) end

---注册清理器
---@public
---@param cleaner function 清理器, 是一个 lua function closure.
---@return nil 
function ILuaEnv:registerCleaner(cleaner) end

---注册软重载闭包. 这个闭包将会在软重启Lua环境时调用.
---@public
---@param luaCallable function 闭包
---@return org.eu.smileyik.luajava.exception.Result 如果注册失败则返回失败信息.
function ILuaEnv:registerSoftReload(luaCallable) end

---将传入的闭包转为 Lua 池用闭包, 该 Lua 池用闭包会运行在其他 Lua 状态机中,在其他 Lua 状态机运行时, 会自动传输该闭包下所用到的一切 `local` 标记的局部变量.在使用中尽量让闭包与当前环境的全局变量无关, 并且尽量使用 Java 实例来传递数值.若一定需要使用某个全局变量, 请以形参方式传输.
---@public
---@param callable function 闭包
---@return function 池化闭包
function ILuaEnv:pooledCallable(callable) end

---获取文件路径.
---@public
---@param path string 文件名
---@return string 文件实际存放的路径.
function ILuaEnv:path(path) end

---获取文件路径.
---@public
---@param paths table 文件名数组
---@return string 文件实际存放的路径.
function ILuaEnv:path(paths) end

---获取文件
---@public
---@param path string 文件名
---@return java.io.File 对应文件实例
function ILuaEnv:file(path) end

---获取文件
---@public
---@param paths table 文件名
---@return java.io.File 对应文件实例
function ILuaEnv:file(paths) end

---当 lua 检索到多个符合要求的方法时, 默认使用第一个方法而非抛出错误.
---@public
---@param flag boolean 开关
---@return nil 
function ILuaEnv:setJustUseFirstMethod(flag) end

---当 lua 检索到多个符合要求的方法时, 默认使用第一个方法而非抛出错误. 并且仅在该闭包内生效.
---@public
---@param callable function 需要忽略多个结果进行运行的闭包
---@return org.eu.smileyik.luajava.exception.Result 
function ILuaEnv:ignoreMultiResultRun(callable) end

return ILuaEnv