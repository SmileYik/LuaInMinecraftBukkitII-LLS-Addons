local function annotationType(diffs, typeMap, localPos, varName, typeName)
    diffs[#diffs+1] = {
        start  = localPos,
        finish = localPos - 1,
        text   = ('---@type %s\n'):format(typeName),
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

local function annotationSimpleCommand(diffs, pos, sender, args, isPlayer)
    local t = "org.bukkit.command.CommandSender"
    if isPlayer then 
        t = "org.bukkit.entity.Player"
    end
    diffs[#diffs+1] = {
        start  = pos,
        finish = pos - 1,
        text   = ([[

        ---@param %s %s command sender
        ---@param %s string[] command args
        ]]):format(sender, t, args),
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

    ------------------- luajava start -------------------

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

    -- return luajava.bindClass
    for localPos, typeName in text:gmatch '()return%s*luajava%.bindClass%s*%(%s*[\'"]([%w_.]+)[\'"]%s*%)' do
        annotationType(diffs, {}, localPos, "1", typeName)
    end

    -- return luajava.createProxy
    for localPos, typeName in text:gmatch '()return%s*luajava%.createProxy%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        annotationType(diffs, {}, localPos, "1", typeName)
    end

    -- return luajava.newInstance
    for localPos, typeName in text:gmatch '()return%s*luajava%.newInstance%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        annotationType(diffs, {}, localPos, "1", typeName)
    end

    ------------------- import start -------------------

    for localPos, varName, colonPos, typeName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*import%s*[%(*%s*[\'"]([%w_.]+)[\'"]%s*%)*()' do
        annotationType(diffs, typeMap, localPos, varName, typeName)
        placedLuajava[colonPos] = true
    end

    for localPos, varName, colonPos, typeName, finish in text:gmatch '()([%w_]+)()%s*=%s*import%s*[%(*%s*[\'"]([%w_.]+)[\'"]%s*%)*()' do
        if not placedLuajava[colonPos] then
            annotationType(diffs, {}, localPos, varName, typeName)
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
    
    local commandFunctionMap = {}

    --- ILuaCommandBuilder:handler
    for pos, sender, args in text:gmatch ':%s*command%s*%(%s*[\'"].+[\'"]%s*%).+:%s*handler%(%s*()function%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)' do
        annotationSimpleCommand(diffs, pos, sender, args, false)
    end

    --- match command like
    --- function [function_name](sender, args)
    --- --- command
    --- end
    for pos, sender, args in text:gmatch '()function%s*[%w_.]*%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)%s*%-%-+%s*command%s' do
        annotationSimpleCommand(diffs, pos, sender, args, false)
    end

    --- match command like
    --- function [function_name](sender, command, label, args)
    --- --- command
    --- end
    for pos, sender, command, label, args in text:gmatch '()function%s*[%w_.]*%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*%)%s*%-%-+%s*command%s' do
        annotationRawCommand(diffs, pos, sender, command, label, args)
    end

    --- match command like
    --- function [function_name](sender, args)
    --- --- command
    --- end
    for pos, sender, args in text:gmatch '()function%s*[%w_.]*%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)%s*%-%-+%s*player%s+command%s' do
        annotationSimpleCommand(diffs, pos, sender, args, true)
    end

    --- registerRawCommand
    for pos, sender, command, label, args in text:gmatch ':registerRawCommand%(%s*[\'"].+[\'"]%s*,%s*()function%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*%)' do
        annotationRawCommand(diffs, pos, sender, command, label, args)
    end

    --- command table
    for commandStart, command, commandEnd in text:gmatch '()command%s*=%s*[\'"]([%w_.]+)[\'"]%s*()' do
        local argsPos = text:match("args%s*=%s*{()")
        local endPos = text:find("}", commandEnd)
        if argsPos then 
            endPos = text:find("}", endPos + 1)
        end
        
        if endPos then
            local t = text:sub(commandEnd, endPos)
            local isPlayer = t:match('()needPlayer%s*=%s*true')
            local pos, sender, args = t:match('handler%s*=%s*()function%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)')
            if pos then
                annotationSimpleCommand(diffs, pos + commandEnd - 1, sender, args, isPlayer ~= nil)
            else 
                local commandFunctionName = (t.." "):match('handler%s*=%s*([%w_.]+)%s*')
                print(t, commandFunctionName)
                if commandFunctionName then
                    commandFunctionMap[commandFunctionName] = {
                        isPlayer = isPlayer ~= nil
                    }
                end
            end
        end
    end

    for pos, name, sender, args in text:gmatch '()function%s*([%w_.]+)%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)' do
        if commandFunctionMap[name] then
            annotationSimpleCommand(diffs, pos, sender, args, commandFunctionMap[name].isPlayer)
        end
    end

    ------------------- event -------------------

    local placedEvent = {}

    --- manual mark event
    --- format
    --- function [function_name](param1)
    --- --- event type
    --- end
    for pos, var, event in text:gmatch '()function%s*[%w_.]*%s*%(%s*([%w_]+)%s*%)%s*%-%-+%s*event%s+([%w_.]+)%s' do
        annotationEvent(diffs, pos, event, var, "by comment")
        placedEvent[pos] = true
    end

    --- luaBukkit.env:onEvent
    for event, pos, var in text:gmatch ':onEvent%(%s*[\'"][%w_.]+[\'"]%s*,%s*[\'"]([%w_.]+)[\'"]%s*,%s*()function%s*%(%s*([%w_]+)%s*%)' do
        if not placedEvent[pos] then
            annotationEvent(diffs, pos, event, var, "by onEvent")
        end
    end

    --- event table
    for eventStart, event, eventEnd in text:gmatch '()event%s*=%s*[\'"]([%w_.]+)[\'"]%s*()' do
        local endPos = text:find("}", eventEnd)
        if endPos then
            local pos, var = text:sub(eventEnd, endPos):match('handler%s*=%s*()function%s*%(%s*([%w_]+)%s*%)')
            if pos and not placedEvent[pos + eventEnd - 1] then
                annotationEvent(diffs, pos + eventEnd - 1, event, var, "by table")
            end
        end
    end

    --- subscribe method
    for event, pos, var in text:gmatch ':subscribe%s*%(%s*[\'"]([%w_.]+)[\'"]%s*,%s*()function%s*%(%s*([%w_]+)%s*%)' do
        if not placedEvent[pos] then
            annotationEvent(diffs, pos, event, var, "by subscribe 1")
        end
    end

    for event, pos, var in text:gmatch ':subscribe%s*%(%s*[\'"]([%w_.]+)[\'"]%s*,[%w%s\'"]+,%s*()function%s*%(%s*([%w_]+)%s*%)' do
        if not placedEvent[pos] then
            annotationEvent(diffs, pos, event, var, "by subscribe 2")
        end
    end

    for event, pos, var in text:gmatch ':subscribe%s*%(%s*[\'"]([%w_.]+)[\'"]%s*,[%w%s\'"]+,[%w%s\'"]+,%s*()function%s*%(%s*([%w_]+)%s*%)' do
        if not placedEvent[pos] then
            annotationEvent(diffs, pos, event, var, "by subscribe 3")
        end
    end

    return diffs
end
