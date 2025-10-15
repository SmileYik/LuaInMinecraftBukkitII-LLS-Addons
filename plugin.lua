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

function InsertPoints:hookFunctionDefine(funcName, callback)
    self.functionHooks[funcName] = callback
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

---
---@return table diffs
function InsertPoints:diffs()
    local diffs = {}
    for pos, text in pairs(self.points) do
        diffs[#diffs + 1] = {
            start  = pos + 1, 
            finish = pos + 1,
            text   = text,
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
---@param source parser.object
---@return string|nil, number|nil, number|nil
local function getCode(state, source)
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

---@param points InsertPoints
---@param state parser.state
---@param source parser.object
local function luajavaGetTypeFromString(points, state, source)
    local arg = parser.guide.getParam(source, 1)
    if arg and parser.guide.isLiteral(arg) then 
        local type = parser.guide.getLiteral(arg)
        points:insert(parser.guide.positionToOffset(state, source.finish), "--[[@as " .. type .. "]]")
        print("----", parser.guide.positionToOffset(state, source.finish), source.finish)
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

local tableHandlers = {
    --- command table handler
    command = {
        match = function(points, state, src)
            return src and "command" == parser.guide.getKeyName(src)
        end,
        handle = function(points, state, tableSrc, machedLineSrc)
            parser.guide.eachChild(tableSrc, function (src)
                if "handler" ~= parser.guide.getKeyName(src) then 
                    return
                end
                parser.guide.eachSource(src, function(a) 
                    print(a.type, getNoSpaceCode(state, a))
                end)
                local flag = false
                parser.guide.eachSourceTypes(src, {"getlocal", "getglobal", "function"}, function(a) 
                    
                    print(a.type, getNoSpaceCode(state, a))
                end)
            end)
        end
    }
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

-- ---@type table<string, InsertPoints>
-- local files = {}
-- ---@param  uri  string # The uri of file
-- ---@param  ast  parser.object # The file ast
-- ---@return parser.object? ast
-- function OnTransformAst(uri, ast)
--     print(2, uri)
--     local state = ast.state --[[@as parser.state]]
--     local points = files[uri] or InsertPoints:new()
--     files[uri] = points
--     points:clear()
--     -- parser.guide.eachSource(ast, function(src) 
--     --     -- print("@" .. src.type, "----", getCode(state, src))
--     --     -- print("----", state.lua:sub(src.start, src.finish))
--     --     -- print(parser.guide.getStartFinish)
--     -- end)
--     parser.guide.eachSourceType(ast, "call", function (src)
--         eachEveryCall(points, state, src)
--     end)
-- end

function OnSetText(uri, text)
    local ast = parser.compile(text, "Lua").ast
    if not ast then return end
    local state = ast.state --[[@as parser.state]]
    local points = InsertPoints:new()

    parser.guide.eachSourceType(ast, "call", function (src)
        eachEveryCall(points, state, src)
    end)
    parser.guide.eachSourceType(ast, "table", function (src)
        eachEveryTable(points, state, src)
    end)

    -- parser.guide.eachSource(ast, function(src) 
    --     print("@" .. src.type, "----", getNoSpaceCode(state, src))
    -- end)

    local diff = points:diffs()
    if #diff > 0 then return diff end
end