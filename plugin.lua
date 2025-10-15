local parser = require 'parser'

---@class InsertPoints
---@field private points table<number, string>
---@field private functionHooks table<string, function> hook function
local InsertPoints = {}
InsertPoints.__index = InsertPoints

---@return InsertPoints
function InsertPoints.new()
    local instance = {
        points = {},
        functionHooks = {}
    }
    return setmetatable(instance, InsertPoints)
end

---@param pos number
---@param source string
function InsertPoints:insert(pos, source)
    self.points[pos] = source
end

function InsertPoints:hookFunctionDefine(funcName, t)
    self.functionHooks[funcName] = t
end

function InsertPoints:getFunctionHook(funcName)
    return self.functionHooks[funcName]
end

function InsertPoints:getSortedPos()
    local sortedPositions = {}
    for pos in pairs(self.points) do
        sortedPositions[#sortedPositions + 1] = pos
    end
    table.sort(sortedPositions)
    return sortedPositions
end

---
---@param text string
function InsertPoints:patch(text)
    local flag = false
    local lua = text
    local poses = self:getSortedPos()
    for i = #poses, 1, -1 do
        local pos = poses[i]
        local text = self.points[pos]
        local head = lua:sub(1, pos)
        local tail = lua:sub(pos + 1)
        lua = head .. text .. tail
        flag = true
    end
    return flag, lua
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

function InsertPoints:clear()
    self.points = {}
end

---get source code range offset
---@param state parser.state
---@param source parser.object
---@return boolean, number, number
local function getOffsetRange(state, source)
    if not state or not source then return false, nil, nil end
    local p, q = parser.guide.getRange(source)
    if not p or not q then return false, nil, nil end
    return true, parser.guide.positionToOffset(state, p) + 1, parser.guide.positionToOffset(state, q)
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
        parser.guide.eachSourceType(funcSource, "funcargs", function(src)
            parser.guide.eachChild(src, function (child)
                local code = getNoSpaceCode(state, child)
                if code and code ~= "" then
                    table.insert(params, code)
                end
            end)
        end)
    end
    return params
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
        -- print("----", parser.guide.positionToOffset(state, source.finish), source.finish, getCode(state, source))
    end
end

local callTable = {
    ["luajava.bindClass"] = luajavaGetTypeFromString,
    ["luajava.newInstance"] = luajavaGetTypeFromString,
    ["luajava.createProxy"] = luajavaGetTypeFromString,
    ["import"] = luajavaGetTypeFromString,
}

--- foreach every call
---@param points InsertPoints
---@param state parser.state
---@param callSrc parser.object
local function eachEveryCall(points, state, callSrc)
    local handled = false
    parser.guide.eachChild(callSrc, function (src)
        local srcText = getNoSpaceCode(state, src)
        if srcText and not handled and callTable[srcText] then
            callTable[srcText](points, state, callSrc)
            handled = true
        end
    end)
end

local tableHandlers = {}

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
        
        local result = false
        local data = {
            isPlayer = "true" == getTableValue(state, tableSrc, "isPlayer", getNoSpaceCode),
            command = getTableValue(state, tableSrc, "command")
        }

        parser.guide.eachSourceTypes(handlerEntry, {"getlocal", "getglobal", "function"}, function (child)
            if result then return end
            if child.type == "function" then
                tableHandlers.command.handleFunction(points, state, handlerEntry, data)
            else
                points:hookFunctionDefine(getCode(state, getTableValueSource(state, handlerEntry)), {
                    handle = tableHandlers.command.handleFunction,
                    data = data
                })
            end
            result = true
        end)

        return result
    end,

    ---@param points InsertPoints
    ---@param state parser.state
    ---@param funcSource parser.object
    ---@param data table<string, any>
    handleFunction = function (points, state, funcSource, data)
        local params = getDefinedFunctionParams(state, funcSource)
        if #params ~= 2 then return end
        local senderType = "org.bukkit.server.CommandSender"
        if data and data.isPlayer then
            senderType = "org.bukkit.entity.Player"
        end
        points:insert(
            parser.guide.positionToOffset(state, funcSource.start), 
            ("\n--- command %s\n---@param %s %s command sender\n---@param %s string[]\n"):format(data.command or "", params[1], senderType, params[2])
        )
    end
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

        parser.guide.eachSourceTypes(handlerEntry, {"getlocal", "getglobal", "function"}, function (child)
            if result then return end
            if child.type == "function" then
                tableHandlers.event.handleFunction(points, state, handlerEntry, data)
            else
                points:hookFunctionDefine(getCode(state, getTableValueSource(state, handlerEntry)), {
                    handle = tableHandlers.event.handleFunction,
                    data = data
                })
            end
            result = true
        end)

        return result
    end,

    ---@param points InsertPoints
    ---@param state parser.state
    ---@param funcSource parser.object
    ---@param data table<string, any>
    handleFunction = function (points, state, funcSource, data)
        local params = getDefinedFunctionParams(state, funcSource)
        if #params ~= 1 then return end
        local eventType = data.event or "any"
        points:insert(
            parser.guide.positionToOffset(state, funcSource.start), 
            ("\n---@param %s %s event instance\n"):format(params[1], eventType)
        )
    end
}

--- foreach every table
---@param points InsertPoints
---@param state parser.state
---@param tableSrc parser.object
local function eachEveryTable(points, state, tableSrc)
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
local function handleSetVarFunction(points, state, setVarSrc)
    local func = nil
    parser.guide.eachSourceType(setVarSrc, "function", function (src)
        if func then return end
        func = src
    end)
    if not func then return end
    local code = getNoSpaceCode(state, setVarSrc) or ""
    -- local	functionaaaa()end	7	26
    -- setglobal	anc=function()end	29	48
    local name = nil
    if code:sub(1, 8) == "function" then
        name = code:match("function([%w_]+)%(")
    else
        name = code:match("^([%w_]+)=")
    end
    if name then
        local t = points:getFunctionHook(name)
        if t and t.handle and type(t.handle) == 'function' then
            t.handle(points, state, func, t.data)
        end
    end
end

--- foreach every function
---@param points InsertPoints
---@param state parser.state
---@param setVarSrc parser.object
local function eachEverySetVar(points, state, setVarSrc)
    handleSetVarFunction(points, state, setVarSrc)
end

function OnSetText(uri, text)
    if text:match("()%-%-%-@meta") then return end
    local ast = parser.compile(text, "Lua").ast
    if not ast then return end
    local state = ast.state --[[@as parser.state]]
    local points = InsertPoints:new()

    parser.guide.eachSourceType(ast, "call", function (src)
        if not src then return end
        eachEveryCall(points, state, src)
    end)
    parser.guide.eachSourceType(ast, "table", function (src)
        if not src then return end
        eachEveryTable(points, state, src)
    end)
    parser.guide.eachSourceTypes(ast, {"setglobal", "local"}, function (src)
        if not src then return end
        eachEverySetVar(points, state, src)
    end)

    -- parser.guide.eachSource(ast, function(src)
    --     if not src then return end
    --     print("@" .. src.type, "----", getNoSpaceCode(state, src))
    -- end)

    local diff = points:diffs(text)
    if #diff > 0 then return diff end
end