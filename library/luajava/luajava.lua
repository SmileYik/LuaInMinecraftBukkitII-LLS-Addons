---@meta luajava

---Luajava
---@class luajava
local luajava = {}

---Get a java class by class name.
---@param className string java class name
---@return any
function luajava.bindClass(className) end

---Convert a java class instance to a java object instance. (Then you can use Class<?> methods)
---@param clazz any java class instance
---@return any
function luajava.class2Obj(clazz) end

---New java class instance
---@param clazz any java class instance
---@param ... any params for constructor
---@return any
function luajava.new(clazz, ...) end

---New java class instance
---@param className string java class name 
---@param ... any params for constructor
---@return any 
function luajava.newInstance(className, ...) end

---Create a Java interface proxy instance
---@param interfaceName string Java interface name
---@param table table A method table. If the key name is the same as the method name in the interface, it is considered a specific implementation of that interface method.
---@return any
function luajava.createProxy(interfaceName, table) end

return luajava