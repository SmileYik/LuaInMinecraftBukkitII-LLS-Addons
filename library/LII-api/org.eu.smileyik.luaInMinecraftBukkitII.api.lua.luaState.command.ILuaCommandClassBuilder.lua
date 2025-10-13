---@meta
---指令类建造器. 指令类是一个包含多条指令的集合, 并且指令类也有自己的名称.<p>    举个例子, 现有如下指令:    <pre><code>        /item get [name]        /item store [name]        /item nbt read [key]        /item nbt write [key] [value]    </code></pre></p><p>    既然指令类是一个包含多条指令的集合, 而每一条实际指令方法之间又没有层级关系,    只能匹配指令的固定词还有它的参数, 那么, 指令之间的层级关系就由指令类之间的层级关系生成.    以上的四条指令可以抽取成两个指令类, 分别如下:    <li>        item 指令类: 包含指令 <code>get [name]</code>, <code>store [name]</code>.    </li>    <li>        nbt 指令类: 包含指令 <code>read [key]</code>, <code>write [key] [value]</code>    </li></p><p>    为了让<code>item</code>指令类与<code>nbt</code>指令类之间有层级关系,我们可以在构建时,    先构造<code>item</code>指令类, 直接使用<code>build(String)</code>方法,    再构造<code>nbt</code>指令类, 使用<code>build(String, String)</code>方法.    之后注册指令时, 就可以将两个指令类型一起注册. 而在 Lua 中的实际注册代码可以参考以下代码:    <pre><code>         -- 构造 item 指令类         local itemCommandClass = luaBukkit.env:commandClassBuilder()            :command("get")      -- get 指令                :args({"name"})                :description("get a item")                :handler(function(sender, args) doSomething() end)            :command("store")    -- store 指令                :args({"name"})                :description("store a item and named it")                :handler(function(sender, args) doSomething() end)            :build("item")         -- 构造 nbt 指令类         local nbtCommandClass = luaBukkit.env:commandClassBuilder()            :command("read")     -- read 指令                :args({"key"})                :description("read item's nbt key")                :handler(function(sender, args) doSomething() end)            :command("write")    -- write 指令                :args({"key", "value"})                :description("write key-value to item' nbt")                :handler(function(sender, args) doSomething() end)            :build("nbt", "item") -- 设定 nbt 类的父指令类为 item 类         -- 注册指令, 并且将最顶层, 也就是没有父指令类的指令类名称写到第一个形参中,         -- 并且将两个指令类组成数组风格的Table, 传入第二个形参.         local result = luaBukkit.env:registerCommand("item", {itemCommandClass, nbtCommandClass})         if result:isError() then luaBukkit.log:info("Register command failed!") end    </code></pre></p>
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder: java.lang.Object
local ILuaCommandClassBuilder = {}

---设定指令别名, 当且仅当该指令为顶级指令时有效
---@public
---@param aliases table 别名
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 构造器
function ILuaCommandClassBuilder:aliases(aliases) end

---设置该类中所有指令都需要玩家才能执行.
---@public
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 该构造器
function ILuaCommandClassBuilder:needPlayer() end

---设置该指令描述
---@public
---@param description string 描述
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 构造器
function ILuaCommandClassBuilder:description(description) end

---设置该类下所有指令所需要的权限.
---@public
---@param permission string 权限
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 构造器
function ILuaCommandClassBuilder:permission(permission) end

---使用指令构造器新建一个指令. 对于它的其他方法重载来讲, 该方法可能更加优雅.
---@public
---@param commandName string 指令名称
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandBuilder 指令构造器
function ILuaCommandClassBuilder:command(commandName) end

---注册一个指令.table格式详细请看<code>CommandProperties</code>类
---@public
---@param table table table, table 必须包含 <code>command</code> 与 <code>handler</code> 字段
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 构造器
function ILuaCommandClassBuilder:command(table) end

---添加若干数量指令
---@public
---@param tables table lua table 数组
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 此构造器
function ILuaCommandClassBuilder:commands(tables) end

---添加一个指令.
---@public
---@param callable function lua闭包
---@param command string 指令名称
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 此构造器
function ILuaCommandClassBuilder:command(callable, command) end

---添加一个指令.
---@public
---@param callable function lua闭包
---@param command string 指令名称
---@param description string 指令描述
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 此构造器
function ILuaCommandClassBuilder:command(callable, command, description) end

---添加一个指令.
---@public
---@param callable function lua闭包
---@param command string 指令名称
---@param args table 指令参数
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 此构造器
function ILuaCommandClassBuilder:command(callable, command, args) end

---添加一个指令.
---@public
---@param callable function lua闭包
---@param command string 指令名称
---@param args table 指令参数
---@param description string 指令描述
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 此构造器
function ILuaCommandClassBuilder:command(callable, command, args, description) end

---添加一个指令.
---@public
---@param callable function lua闭包
---@param command string 指令名称
---@param args table 指令参数
---@param description string 指令描述
---@param permission string 指令权限
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 此构造器
function ILuaCommandClassBuilder:command(callable, command, args, description, permission) end

---添加一个指令.
---@public
---@param callable function lua闭包
---@param command string 指令名称
---@param args table 指令参数
---@param description string 指令描述
---@param permission string 指令权限
---@param needPlayer boolean 是否需要玩家执行
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 此构造器
function ILuaCommandClassBuilder:command(callable, command, args, description, permission, needPlayer) end

---添加一个指令.
---@public
---@param callable function lua闭包
---@param command string 指令名称
---@param args table 指令参数
---@param description string 指令描述
---@param permission string 指令权限
---@param needPlayer boolean 是否需要玩家执行
---@param unlimitedArgs boolean 是否无限参数长度
---@return org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.command.ILuaCommandClassBuilder 此构造器
function ILuaCommandClassBuilder:command(callable, command, args, description, permission, needPlayer, unlimitedArgs) end

---构建指令类型.
---@public
---@param metaTable table lua table,                     有效字段为 command(必填),                     aliases, description, permission, needPlayer, parentCommand
---@param commandTables table 与commands方法类似.
---@return java.lang.Class 指令类型
function ILuaCommandClassBuilder:build(metaTable, commandTables) end

---构建指令
---@public
---@param command string 根指令名
---@return java.lang.Class 构建好的指令类
function ILuaCommandClassBuilder:build(command) end

---构建指令, 并将次类型归类在指定父级指令下. 例如有两个指令类,<li>    指令类1的顶级指令名为 <code>item</code>, 其中包含子指令: <code>get</code>, <code>set</code></li><li>    指令类2的顶级指令名为 <code>nbt</code>, 其中包含子指令: <code>read</code>, <code>clear</code>.</li>此时构建指令时, 将指令2的父级指令名设置为指令1, 注册完指令后, 实际生成的指令是这样的:<pre><code>     /item get     /item set     /item nbt read     /item nbt clear</code></pre>
---@public
---@param command string 顶级指令名
---@param parentCommand string 父级指令名
---@return java.lang.Class 构建好的指令类
function ILuaCommandClassBuilder:build(command, parentCommand) end

return ILuaCommandClassBuilder