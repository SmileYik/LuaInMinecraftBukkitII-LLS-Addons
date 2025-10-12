---@meta env
---@class env
local env = {}

---Get a Bukkit event listener builder, to register Bukkit event.
---@return any
function env:listenerBuilder() end

function env:unregisterEventListener(name) end

return env