---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.LuaHelper: java.lang.Object
local LuaHelper = {}

---构建一个 Runnable 实例.
---@public
---@param callable function Lua 闭包
---@return java.lang.Runnable Runnable 实例.
function LuaHelper:runnable(callable) end

---构建一个 Consumer 实例
---@public
---@param callable function Lua 闭包
---@return java.util.function.Consumer Consumer 实例
function LuaHelper:consumer(callable) end

---构建一个 Function 实例
---@public
---@param callable function Lua 闭包
---@return java.util.function.Function Function 实例
function LuaHelper:function(callable) end

---构建一个不安全的 Lua Function, 该 Function 不受锁保护. 在多线程情况下可能会出现问题.<strong>这可能会导致段错误, 从而引发JVM崩溃!</strong>
---@public
---@return function 
function LuaHelper:unsafeCallable(callable) end

---同步运行 Lua 闭包
---@public
---@param callable function Lua 闭包
---@return java.util.concurrent.CompletableFuture Future<Object>
function LuaHelper:syncCall(callable) end

---同步运行 Lua 闭包, 并传入参数.
---@public
---@param callable function Lua 闭包
---@param params table 传入 Lua 闭包的参数.
---@return java.util.concurrent.CompletableFuture Future<Object>
function LuaHelper:syncCall(callable, params) end

---同步延迟运行 Lua 闭包
---@public
---@param callable function Lua 闭包
---@param tick number 延迟, 单位: tick
---@return java.util.concurrent.CompletableFuture Future<Object>
function LuaHelper:syncCallLater(callable, tick) end

---同步延迟运行 Lua 闭包
---@public
---@param callable function Lua 闭包
---@param tick number 延迟, 单位: tick
---@param params table 传入闭包的参数.
---@return java.util.concurrent.CompletableFuture Future<Object>
function LuaHelper:syncCallLater(callable, tick, params) end

---同步执行计时器. 调用该方法则有责任管理该计时器, 请在不需要的时候释放它.
---@public
---@param callable function Lua 闭包
---@param delay number 延迟执行, 单位: tick
---@param period number 间隔执行, 单位: tick
---@return org.eu.smileyik.luaInMinecraftBukkitII.scheduler.ScheduledTaskWrapper ScheduledTaskWrapper<?>.
function LuaHelper:syncTimer(callable, delay, period) end

---同步执行计时器. 调用该方法则有责任管理该计时器, 请在不需要的时候释放它.
---@public
---@param callable function Lua 闭包
---@param delay number 延迟执行, 单位: tick
---@param period number 间隔执行, 单位: tick
---@param params table 传入闭包参数.
---@return org.eu.smileyik.luaInMinecraftBukkitII.scheduler.ScheduledTaskWrapper ScheduledTaskWrapper<?>
function LuaHelper:syncTimer(callable, delay, period, params) end

---异步调用 Lua 闭包.
---@public
---@param callable function Lua 闭包
---@return java.util.concurrent.CompletableFuture Future<Object>
function LuaHelper:asyncCall(callable) end

---异步调用 Lua 闭包.
---@public
---@param callable function Lua 闭包
---@param params table 传入闭包的参数
---@return java.util.concurrent.CompletableFuture Future<Object>
function LuaHelper:asyncCall(callable, params) end

---异步调用 Lua 闭包.
---@public
---@param callable function Lua 闭包
---@param tick number 延迟执行, 单位: tick
---@return java.util.concurrent.CompletableFuture Future<Object>
function LuaHelper:asyncCallLater(callable, tick) end

---异步调用 Lua 闭包.
---@public
---@param callable function Lua 闭包
---@param tick number 延迟执行, 单位: tick
---@param params table 传入闭包的参数
---@return java.util.concurrent.CompletableFuture Future<Object>
function LuaHelper:asyncCallLater(callable, tick, params) end

---异步调用 Lua 闭包.
---@public
---@param callable function Lua 闭包
---@param delay number 延迟执行, 单位: tick
---@param period number 间隔执行, 单位: tick
---@return org.eu.smileyik.luaInMinecraftBukkitII.scheduler.ScheduledTaskWrapper Future<Object>
function LuaHelper:asyncTimer(callable, delay, period) end

---异步调用 Lua 闭包.
---@public
---@param callable function Lua 闭包
---@param delay number 延迟执行, 单位: tick
---@param period number 间隔执行, 单位: tick
---@param params table 传入闭包的参数
---@return org.eu.smileyik.luaInMinecraftBukkitII.scheduler.ScheduledTaskWrapper Future<Object>
function LuaHelper:asyncTimer(callable, delay, period, params) end

---将 lua 中的数组风格表转换为指定类型的 Java 数组.
---@public
---@param className string 类型全类名
---@param array table lua 中数组风格表
---@return java.util.Optional Java 数组
function LuaHelper:castArray(className, array) end

---将 lua 中的数组风格表转换为指定类型的 Java 数组.
---@public
---@param type java.lang.Class 类型
---@param array table lua 中数组风格表
---@return java.util.Optional Java 数组
function LuaHelper:castArray(type, array) end

return LuaHelper