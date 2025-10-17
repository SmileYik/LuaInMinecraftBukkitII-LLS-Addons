local parser = require 'parser'

---@class FunctionHandler
---@field offset number code offset
---@field handle function handle method
---@field data table the data
---@field type string handler type
local FunctionHandler = {}

local tableHandlers = {}

---@class InsertPoints
---@field private points table<number, string>
---@field private functionHooks table<string, FunctionHandler[]> hook function0
local InsertPoints = {}
InsertPoints.__index = InsertPoints


---get source code range offset
---@param state parser.state
---@param source parser.object
---@return boolean, number, number
local function getOffsetRange(state, source)
    if not state or not source then return false, nil, nil end
    local p, q = parser.guide.getRange(source)
    if p then p = parser.guide.positionToOffset(state, p) + 1 end
    if q then q = parser.guide.positionToOffset(state, q) end
    return p and q and true or false, p, q
end

---get source code
---@param state parser.state
---@param source? parser.object
---@return string|nil, number|nil, number|nil
local function getCode(state, source)
    if not source then return nil end
    local result, p, q = getOffsetRange(state, source)
    if result then
        return state.lua:sub(p, q), p, q
    end
    return nil
end

---get source code
---@param state parser.state
---@param source parser.object
---@return string|nil, number|nil, number|nil
local function getNoSpaceCode(state, source)
    local code, p, q = getCode(state, source)
    if code then return code:gsub("%s", ""), p, q end
    return nil
end

---@return InsertPoints
function InsertPoints.new()
    local instance = {
        points = {},
        functionHooks = {},
        globals = {},
        headBlock = nil
    }
    return setmetatable(instance, InsertPoints)
end

--- insert source at target point(offset)
---@param pos number
---@param source string
function InsertPoints:insert(pos, source)
    self.points[pos] = source
end

---hook function defined
---@param funcName string?
---@param handler FunctionHandler
function InsertPoints:hookFunctionDefine(funcName, handler)
    if funcName then
        self.functionHooks[funcName] = self.functionHooks[funcName] or {}
        table.insert(self.functionHooks[funcName], handler)
    end
end

---get real function position
---@return table<parser.object, FunctionHandler> map setvalue source to handler
function InsertPoints:getFunctionHooks()
    local result = {}
    for funcName, handlers in pairs(self.functionHooks) do
        for _, handler in ipairs(handlers) do
            local setVar = self:findVar(funcName, handler.offset)
            if setVar then
                result[setVar] = handler
            end
        end
    end
    return result
end

---@param lua string lua source
---@return table diffs
function InsertPoints:diffs(lua)
    local diffs = {}
    for pos, text in pairs(self.points) do
        diffs[#diffs + 1] = {
            start  = pos,
            finish = pos,
            text   = lua:sub(pos, pos) .. text,
        }
    end
    return diffs
end

---scan ast block
---@param state parser.state
---@param ast parser.object
function InsertPoints:scanBlock(state, ast)
    local globals = {}
    local tail = nil
    if ast.finish then tail = parser.guide.offsetToPosition(state, ast.finish) end
    local head = {
        offset = parser.guide.offsetToPosition(state, ast.start),
        tail = tail,
        src = ast,
        locals = {},
        children = {}
    }

    ---@param src parser.object
    local function foreach (src, node, deep)
        parser.guide.eachChild(src, function (child)
            if not child then return end
            if parser.guide.blockTypes[child.type] then
                local _, offset, tail = getOffsetRange(state, child)
                local t = {
                    offset = offset,
                    tail = tail,
                    src = child,
                    locals = {},
                    children = {}
                }
                table.insert(node.children, t)
                foreach(child, t, deep + 1)
            elseif child.type == "local" or child.type == "setlocal" then
                local var = parser.guide.getKeyName(child)
                if var then
                    local _, offset = getOffsetRange(state, child)
                    node.locals[var] = node.locals[var] or {}
                    table.insert(node.locals[var], {
                        offset = offset,
                        src = child
                    })
                end
                foreach(child, node, deep + 1)
            elseif child.type == "setglobal" then
                local var = parser.guide.getKeyName(child)
                if var then
                    local _, offset = getOffsetRange(state, child)
                    globals[var] = globals[var] or {}
                    table.insert(globals[var], {
                        offset = offset,
                        src = child
                    })
                end
                foreach(child, node, deep + 1)
            else
                foreach(child, node, deep + 1)
            end
        end)      
    end
    foreach(ast, head, 0)
    return head, globals
end

---analyze block
---@param state parser.state
---@param ast parser.object
function InsertPoints:analyze(state, ast)
    self.headBlock, self.globals = self:scanBlock(state, ast)
end

---find local variable
---@param name string
---@param offset? number
---@return parser.object?, number
function InsertPoints:findLocalVar(name, offset)
    offset = offset or 0
    local mostNear = -1
    local result = nil
    local function search(node)
        for _, var in ipairs(node.locals[name] or {}) do
            local sub = offset - var.offset
            if sub > 0 and (mostNear == -1 or sub < mostNear) then
                result = var.src
                mostNear = sub
            end
        end
        
        for i = #node.children, 1, -1 do
            local child = node.children[i]
            if child.offset <= offset and (child.tail or offset) >= offset then
                search(child)
                return
            end
        end
    end
    search(self.headBlock)
    return result, mostNear
end

---find global variable
---@param name string
---@param offset? number
---@return parser.object?, number
function InsertPoints:findGlobalVar(name, offset)
    offset = offset or 0
    local mostNear = -1
    local result = nil
    for _, var in ipairs(self.globals[name] or {}) do
        local sub = offset - var.offset
        if sub > 0 and (mostNear == -1 or sub < mostNear) then
            result = var.src
            mostNear = sub
        end
    end
    return result, mostNear
end


---find variable
---@param name string
---@param offset? number
---@return parser.object?
function InsertPoints:findVar(name, offset)
    offset = offset or 0
    local result1, near1 = self:findGlobalVar(name, offset)
    local result2, near2 = self:findLocalVar(name, offset)
    if near1 == -1 then
        return result2
    elseif near2 == -1 then
        return result1
    elseif near1 < near2 then
        return result1
    else
        return result2
    end
end

---@param state parser.state
---@param entrySource? parser.object
---@return parser.object?
local function getTableValueSource(state, entrySource)
    if not entrySource then return nil end
    local key = parser.guide.getKeyName(entrySource)
    if key then
        local target = nil
        parser.guide.eachChild(entrySource, function(src)
            if getNoSpaceCode(state, src) == key then
                return
            end
            target = src
        end)
        return target
    end
    return nil
end

---get target entry from table source
---@param tableSource? parser.object
---@param targetKey string target key
---@return parser.object?
local function getTableEntrySource(tableSource, targetKey)
    if not tableSource or tableSource.type ~= "table" then
        return nil
    end

    local target = nil
    parser.guide.eachChild(tableSource, function(child)
        if target then return end
        local key = parser.guide.getKeyName(child)
        if key and key == targetKey then
            target = child
        end
    end)
    return target
end

---get defined function's params
---@param state parser.state
---@param funcSource parser.object?
---@return string[]
local function getDefinedFunctionParams(state, funcSource)
    local params = {}
    if funcSource then
        if funcSource.type ~= "function" then
            parser.guide.eachChild(funcSource, function (src)
                if funcSource.type ~= "function" and src and src.type == "function" then
                    funcSource = src
                end
            end)
        end
        parser.guide.eachChild(funcSource, function (src)
            if src and src.type == "funcargs" then
                parser.guide.eachChild(src, function (child)
                    local code = getNoSpaceCode(state, child)
                    if code and code ~= "" then
                        table.insert(params, code)
                    end
                end)
            end
        end)
    end
    return params
end

--- find real defined var
---@param points InsertPoints
---@param state parser.state
---@param varSrc parser.object
local function getRealDefinedVar(points, state, varSrc)
    local targetSrc = nil
    parser.guide.eachChild(varSrc, function(src) 
        if not targetSrc and src and (src.type == "getlocal" or src.type == "getglobal") then
            targetSrc = src
        end
    end)
    if targetSrc then
        local varName = parser.guide.getKeyName(targetSrc)
        if varName then
            local offset = parser.guide.positionToOffset(state, varSrc.start)
            local result = points:findVar(varName, offset)
            if result then
                return getRealDefinedVar(points, state, result)
            end
        end
    end
    return varSrc
end

---@param state parser.state
---@param tableSource parser.object?
---@param targetKey string
---@param getCodeFunc function? get code func or get literal
---@return string?
local function getTableValue(state, tableSource, targetKey, getCodeFunc)
    local src = getTableValueSource(state, getTableEntrySource(tableSource, targetKey))
    local result = nil
    if getCodeFunc then
        result = getCodeFunc(state, src)
    elseif src and parser.guide.isLiteral(src) then
        result = parser.guide.getLiteral(src)
    end
    return result
end

---@param points InsertPoints
---@param state parser.state
---@param source parser.object
local function luajavaGetTypeFromString(points, state, source)
    local arg = parser.guide.getParam(source, 1)
    if arg and parser.guide.isLiteral(arg) then
        local type = parser.guide.getLiteral(arg)
        points:insert(parser.guide.positionToOffset(state, source.finish), "--[[@as " .. type .. "]]")
    end
end

---@param points InsertPoints
---@param state parser.state
---@param funcSource parser.object
---@param data table<string, any>
local function hookBukkitEvent(points, state, funcSource, data)
    local params = getDefinedFunctionParams(state, funcSource)
    if #params ~= 1 then return end
    local eventType = data.event or "any"
    points:insert(
        parser.guide.positionToOffset(state, funcSource.start),
        ("\n---@param %s %s event instance\n"):format(params[1], eventType)
    )
end

---@param points InsertPoints
---@param state parser.state
---@param source parser.object the source include function or variable
local function handleBukkitEvent(points, state, source, data)
    local sources = {
        ["function"] = source.type == 'function' and source,
        ["getlocal"] = source.type == 'getlocal' and source,
        ["getglobal"] = source.type == 'getglobal' and source,
    }
    parser.guide.eachChild(source, function (src)
        if src and not sources[src.type] then
            sources[src.type] = src
        end
    end)

    if sources["function"] then
        hookBukkitEvent(points, state, source, data)
        return true
    end

    local child = sources["getlocal"] or sources["getglobal"] or nil
    if child then
        local targetSource = getTableValueSource(state, source) or child
        points:hookFunctionDefine(getCode(state, targetSource), {
            offset = parser.guide.positionToOffset(state, targetSource.start),
            handle = hookBukkitEvent,
            data = data,
            type = "table-event"
        })
        return true
    end

    return false
end

---@param points InsertPoints
---@param state parser.state
---@param funcSource parser.object
---@param data table<string, any>
local function hookBukkitCommandSimple(points, state, funcSource, data)
    local params = getDefinedFunctionParams(state, funcSource)
    if #params ~= 2 then return end
    local senderType = "org.bukkit.command.CommandSender"
    if data and data.isPlayer then
        senderType = "org.bukkit.entity.Player"
    end
    points:insert(
        parser.guide.positionToOffset(state, funcSource.start), 
        ("\n--- command %s\n---@param %s %s command sender\n---@param %s string[] args\n"):format(data.command or "", params[1], senderType, params[2])
    )
end

---@param points InsertPoints
---@param state parser.state
---@param funcSource parser.object
---@param data table<string, any>
local function hookBukkitCommandRaw(points, state, funcSource, data)
    local params = getDefinedFunctionParams(state, funcSource)
    if #params ~= 4 then return end
    local senderType = "org.bukkit.command.CommandSender"
    if data and data.isPlayer then
        senderType = "org.bukkit.entity.Player"
    end
    points:insert(
        parser.guide.positionToOffset(state, funcSource.start),
        ([[
--- command %s
---@param %s %s command sender
---@param %s org.bukkit.command.Command command instance
---@param %s string command label
---@param %s string[] command args
---@return boolean
]]):format(data.command or "", params[1], senderType, params[2], params[3], params[4])
    )
end

---@param points InsertPoints
---@param state parser.state
---@param source parser.object the source include function or variable
---@param data table
---@param handler function?
local function handleBukkitCommand(points, state, source, data, handler)
    handler = handler or hookBukkitCommandSimple
    local sources = {
        ["function"] = source.type == 'function' and source,
        ["getlocal"] = source.type == 'getlocal' and source,
        ["getglobal"] = source.type == 'getglobal' and source,
    }
    parser.guide.eachChild(source, function (src)
        if src and not sources[src.type] then
            sources[src.type] = src
        end
    end)

    if sources["function"] then
        handler(points, state, source, data)
        return true
    end

    local child = sources["getlocal"] or sources["getglobal"] or nil
    if child then
        local target = getTableValueSource(state, source) or source
        points:hookFunctionDefine(getCode(state, target), {
            offset = parser.guide.positionToOffset(state, target.start),
            handle = handler,
            data = data,
            type = "table-command"
        })
        return true
    end
    return false
end

local callTable = {
    ["luajava.bindClass"] = luajavaGetTypeFromString,
    ["luajava.newInstance"] = luajavaGetTypeFromString,
    ["import"] = luajavaGetTypeFromString,

    ---@param points InsertPoints
    ---@param state parser.state
    ---@param source parser.object
    ["luajava.createProxy"] = function (points, state, source)
        local arg = parser.guide.getParam(source, 1)
        if arg and parser.guide.isLiteral(arg) then
            local type = parser.guide.getLiteral(arg)
            points:insert(parser.guide.positionToOffset(state, source.finish), "--[[@as " .. type .. "]]")
            
            local arg2 = parser.guide.getParam(source, 2)
            if arg2 then
                points:insert(parser.guide.positionToOffset(state, arg2.finish), "--[[@as " .. type .. "]]")
            end
        end
    end,

    ---@param points InsertPoints
    ---@param state parser.state
    ---@param source parser.object
    ["luaBukkit.env:onEvent"] = function (points, state, source)
        local eventSrc = parser.guide.getParam(source, 3)
        local funcSrc = parser.guide.getParam(source, 4)
        if eventSrc and funcSrc and parser.guide.isLiteral(eventSrc) then
            local event = parser.guide.getLiteral(eventSrc)
            handleBukkitEvent(points, state, funcSrc, {
                event = event
            })
        end
    end,

    ---@param points InsertPoints
    ---@param state parser.state
    ---@param source parser.object
    ["luaBukkit.env:registerRawCommand"] = function (points, state, source)
        local commandSrc = parser.guide.getParam(source, 2)
        local funcSrc = parser.guide.getParam(source, 3)
        if commandSrc and funcSrc and parser.guide.isLiteral(commandSrc) then
            local command = parser.guide.getLiteral(commandSrc)
            handleBukkitCommand(points, state, funcSrc, {
                command = command
            }, hookBukkitCommandRaw)
        end
    end
}

---luajava.new
---@param points InsertPoints
---@param state parser.state
---@param source parser.object
callTable["luajava.new"] = function (points, state, source)
    local arg = parser.guide.getParam(source, 1)
    if arg then
        local varName = parser.guide.getKeyName(arg)
        if varName then
            local var = points:findVar(varName, parser.guide.positionToOffset(state, source.finish))
            if var then
                var = getRealDefinedVar(points, state, var)
                parser.guide.eachSourceType(var, "call", function (callSrc)
                    parser.guide.eachChild(callSrc, function (src)
                        local srcText = getNoSpaceCode(state, src)
                        if callTable[srcText] then
                            local t = parser.guide.getParam(callSrc, 1)
                            if t and parser.guide.isLiteral(t) then
                                local type = parser.guide.getLiteral(t)
                                points:insert(parser.guide.positionToOffset(state, source.finish), "--[[@as " .. type .. "]]")
                            end
                        end
                    end)
                end)
            end
        end
    end
end

--- foreach all function call
---@param points InsertPoints
---@param state parser.state
---@param callSrc parser.object
local function eachCall(points, state, callSrc)
    local handled = false
    parser.guide.eachChild(callSrc, function (src)
        local srcText = getNoSpaceCode(state, src)
        if srcText and not handled and callTable[srcText] then
            callTable[srcText](points, state, callSrc)
            handled = true
        end
    end)
end

tableHandlers.command = {
    match = function(points, state, src)
        return src and "command" == parser.guide.getKeyName(src)
    end,

    ---@param points InsertPoints
    ---@param state parser.state
    ---@param tableSrc parser.object
    handle = function(points, state, tableSrc, machedLineSrc)
        local handlerEntry = getTableEntrySource(tableSrc, "handler")
        if not handlerEntry then return false end
        local data = {
            isPlayer = "true" == getTableValue(state, tableSrc, "needPlayer", getNoSpaceCode),
            command = getTableValue(state, tableSrc, "command")
        }
        return handleBukkitCommand(points, state, handlerEntry, data, hookBukkitCommandSimple)
    end,
    handleFunction = hookBukkitCommandSimple
}

tableHandlers.event = {
    match = function(points, state, src)
        return src and "event" == parser.guide.getKeyName(src)
    end,

    ---@param points InsertPoints
    ---@param state parser.state
    ---@param tableSrc parser.object
    handle = function(points, state, tableSrc, machedLineSrc)
        local handlerEntry = getTableEntrySource(tableSrc, "handler")
        if not handlerEntry then return false end
        
        local result = false
        local data = { event = getTableValue(state, tableSrc, "event") }
        return handleBukkitEvent(points, state, handlerEntry, data)
    end,
    handleFunction = hookBukkitEvent
}

--- foreach every table
---@param points InsertPoints
---@param state parser.state
---@param tableSrc parser.object
local function eachTable(points, state, tableSrc)
    local handled = false
    parser.guide.eachChild(tableSrc, function (src)
        if handled then return end
        for _, handler in pairs(tableHandlers) do
            handled = (handler.match(points, state, src) and 
                        handler.handle(points, state, tableSrc, src)) or false
            if handled then break end
        end
    end)
end

--- foreach every function
---@param points InsertPoints
---@param state parser.state
---@param setVarSrc parser.object
---@param t FunctionHandler
local function handleSetVarFunction(points, state, setVarSrc, t)
    setVarSrc = getRealDefinedVar(points, state, setVarSrc)
    local func = nil
    parser.guide.eachChild(setVarSrc, function (src)
        if func or not src or src.type ~= "function" then return end
        func = src
    end)
    if not func then return end

    -- has function
    if t and t.handle and type(t.handle) == 'function' then
        t.handle(points, state, func, t.data)
    end
end

function OnSetText(uri, text)
    if text:match("()%-%-%-@meta") then return end
    local ast = parser.compile(text, "Lua").ast
    if not ast then return end
    local state = ast.state --[[@as parser.state]]
    local points = InsertPoints:new()

    points:analyze(state, ast)
    parser.guide.eachSourceType(ast, "call", function (src)
        if not src then return end
        eachCall(points, state, src)
    end)
    parser.guide.eachSourceType(ast, "table", function (src)
        if not src then return end
        eachTable(points, state, src)
    end)

    for setVar, t in pairs(points:getFunctionHooks()) do
        handleSetVarFunction(points, state, setVar, t)
    end
    
    return points:diffs(text)
end