local function annotationType(diffs, typeMap, localPos, varName, typeName)
    diffs[#diffs+1] = {
        start  = localPos,
        finish = localPos - 1,
        text   = ('\n---@type %s\n'):format(typeName),
    }
    typeMap[varName] = typeName
end

local function annotationRawCommand(diffs, pos, sender, command, label, args)
    diffs[#diffs+1] = {
        start  = pos,
        finish = pos - 1,
        text   = ([[

        ---@param %s org.bukkit.command.CommandSender command sender
        ---@param %s org.bukkit.command.Command command
        ---@param %s string command label
        ---@param %s string[] command args
        ---@return boolean result you should return `true` or `false`
        ]]):format(sender, command, label, args),
    }
end

local function annotationSimpleCommand(diffs, pos, sender, args)
    diffs[#diffs+1] = {
        start  = pos,
        finish = pos - 1,
        text   = ([[

        ---@param %s org.bukkit.command.CommandSender command sender
        ---@param %s string[] command args
        ]]):format(sender, args),
    }
end

local function annotationEvent(diffs, pos, event, var, mark)
    if mark == nil then mark = "mark" end
    diffs[#diffs+1] = {
        start  = pos,
        finish = pos - 1,
        text   = ([[
        
        ---%s
        ---@param %s %s event instance
        ]]):format(mark, var, event),
    }
end

function OnSetText(uri, text)

    for _ in text:gmatch '()%s*%-%-+@meta' do
        return
    end

    local diffs = {}
    local typeMap = {}
    local placedLuajava = {}

    -- local var = luajava.bindClass
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*luajava%.bindClass%s*%(%s*[\'"]([%w_.]+)[\'"]%s*%)()' do
        annotationType(diffs, typeMap, localPos, varName, typeName)
        placedLuajava[colonPos] = true
    end

    -- local var = luajava.newInstance
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*luajava%.newInstance%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        annotationType(diffs, typeMap, localPos, varName, typeName)
        placedLuajava[colonPos] = true
    end

    -- local var = luajava.createProxy
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*luajava%.createProxy%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        annotationType(diffs, typeMap, localPos, varName, typeName)
        placedLuajava[colonPos] = true
    end

    -- local var = luajava.new
    for localPos, varName, colonPos, otherVarName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*luajava%.new%s*%(%s*([%w_.]+)()' do
        if typeMap[otherVarName] then
            local typeName = typeMap[otherVarName]
            annotationType(diffs, typeMap, localPos, varName, typeName)
            placedLuajava[colonPos] = true
        end
    end

    ------------------- table start -------------------

    -- table: var = luajava.bindClass
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()([%w_]+)()%s*=%s*luajava%.bindClass%s*%(%s*[\'"]([%w_.]+)[\'"]%s*%)()' do
        if not placedLuajava[colonPos] then
            annotationType(diffs, {}, localPos, varName, typeName)
        end
    end

    -- table: var = luajava.newInstance
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()([%w_]+)()%s*=%s*luajava%.newInstance%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        if not placedLuajava[colonPos] then
            annotationType(diffs, {}, localPos, varName, typeName)
        end
    end

    -- table: var = luajava.createProxy
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()([%w_]+)()%s*=%s*luajava%.createProxy%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        if not placedLuajava[colonPos] then
            annotationType(diffs, {}, localPos, varName, typeName)
        end
    end

    ------------------- command -------------------
    
    --- ILuaCommandBuilder:handler
    for pos, sender, args in text:gmatch ':%s*command%s*%(%s*[\'"].+[\'"]%s*%).+:%s*handler%(%s*()function%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)' do
        annotationSimpleCommand(diffs, pos, sender, args)
    end

    --- match command like
    --- function [function_name](sender, args)
    --- --- command
    --- end
    for pos, sender, args in text:gmatch '()function%s*[%w_.]*%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)%s*%-%-+%s*command%s' do
        annotationSimpleCommand(diffs, pos, sender, args)
    end

    --- match command like
    --- function [function_name](sender, command, label, args)
    --- --- command
    --- end
    for pos, sender, command, label, args in text:gmatch '()function%s*[%w_.]*%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*%)%s*%-%-+%s*command%s' do
        annotationRawCommand(diffs, pos, sender, command, label, args)
    end

    --- registerRawCommand
    for pos, sender, command, label, args in text:gmatch ':registerRawCommand%(%s*[\'"].+[\'"]%s*,%s*()function%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*%)' do
        annotationRawCommand(diffs, pos, sender, command, label, args)
    end

    ------------------- event -------------------
    
    --- luaBukkit.env:onEvent
    for event, pos, var in text:gmatch ':onEvent%(%s*[\'"][%w_.]+[\'"]%s*,%s*[\'"]([%w_.]+)[\'"]%s*,%s*()function%s*%(%s*([%w_]+)%s*%)' do
        annotationEvent(diffs, pos, event, var, "by onEvent")
    end

    --- event table
    for eventStart, event, eventEnd in text:gmatch '()event%s*=%s*[\'"]([%w_.]+)[\'"]%s*()' do
        local endPos = text:find("}", eventEnd)
        if endPos then
            local pos, var = text:sub(eventEnd, endPos):match('handler%s*=%s*()function%s*%(%s*([%w_]+)%s*%)')
            if pos then
                annotationEvent(diffs, pos + eventEnd - 1, event, var, "by table")
            end
        end
    end

    --- manual mark event
    --- format
    --- function [function_name](param1)
    --- --- event type
    --- end
    for pos, var, event in text:gmatch '()function%s*[%w_.]*%s*%(%s*([%w_]+)%s*%)%s*%-%-+%s*event%s+([%w_.]+)%s' do
        annotationEvent(diffs, pos, event, var, "by comment")
    end

    for event, pos, var in text:gmatch ':subscribe%s*%(%s*[\'"]([%w_.]+)[\'"]%s*,%s*()function%s*%(%s*([%w_]+)%s*%)' do
        annotationEvent(diffs, pos, event, var, "by subscribe 1")
    end

    for event, pos, var in text:gmatch ':subscribe%s*%(%s*[\'"]([%w_.]+)[\'"]%s*,[%w%s\'"]+,%s*()function%s*%(%s*([%w_]+)%s*%)' do
        annotationEvent(diffs, pos, event, var, "by subscribe 2")
    end

    for event, pos, var in text:gmatch ':subscribe%s*%(%s*[\'"]([%w_.]+)[\'"]%s*,[%w%s\'"]+,[%w%s\'"]+,%s*()function%s*%(%s*([%w_]+)%s*%)' do
        annotationEvent(diffs, pos, event, var, "by subscribe 3")
    end

    return diffs
end
