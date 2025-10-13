local function annotationType(diffs, typeMap, localPos, varName, typeName)
    diffs[#diffs+1] = {
        start  = localPos,
        finish = localPos - 1,
        text   = ('---@type %s\n'):format(typeName),
    }
    typeMap[varName] = typeName
end

local function annotationTypeForNotLocal(diffs, typeMap, text, localPos, varName, typeName)
    local trimmed_end = text:match("(%S+)%s*$")
    if trimmed_end and #trimmed_end >= #"local" and "local" == string.sub(text, #trimmed_end - 5, #trimmed_end) then return end
    if trimmed_end then
    diffs[#diffs+1] = {
        start  = localPos,
        finish = localPos - 1,
        text   = ('\n---@type %s\n'):format(typeName),
    }
end
    diffs[#diffs+1] = {
        start  = localPos,
        finish = localPos - 1,
        text   = ('\n---@type %s\n'):format(typeName),
    }
    typeMap[varName] = typeName
end

function OnSetText(uri, text)
    local diffs = {}
    local typeMap = {}

    -- local var = luajava.bindClass
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*luajava%.bindClass%s*%(%s*[\'"]([%w_.]+)[\'"]%s*%)()' do
        annotationType(diffs, typeMap, localPos, varName, typeName)
    end

    -- local var = luajava.newInstance
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*luajava%.newInstance%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        annotationType(diffs, typeMap, localPos, varName, typeName)
    end

    -- local var = luajava.createProxy
    for localPos, varName, colonPos, typeName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*luajava%.createProxy%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        annotationType(diffs, typeMap, localPos, varName, typeName)
    end

    -- local var = luajava.new
    for localPos, varName, colonPos, otherVarName, finish in text:gmatch '()local%s+([%w_]+)()%s*=%s*luajava%.new%s*%(%s*([%w_.]+)()' do
        if typeMap[otherVarName] then
            local typeName = typeMap[otherVarName]
            annotationType(diffs, typeMap, localPos, varName, typeName)
        end
    end

    ------------------- table start -------------------

    -- table: var = luajava.bindClass
    for _, localPos, varName, colonPos, typeName, finish in text:gmatch '([%g%s]*)()([%w_]+)()%s*=%s*luajava%.bindClass%s*%(%s*[\'"]([%w_.]+)[\'"]%s*%)()' do
        annotationType(diffs, {}, localPos, varName, typeName)
    end

    -- table: var = luajava.newInstance
    for _, localPos, varName, colonPos, typeName, finish in text:gmatch '([%g%s]*)()([%w_]+)()%s*=%s*luajava%.newInstance%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        annotationType(diffs, {}, localPos, varName, typeName)
    end

    -- table: var = luajava.createProxy
    for _, localPos, varName, colonPos, typeName, finish in text:gmatch '([%g%s]*)()([%w_]+)()%s*=%s*luajava%.createProxy%s*%(%s*[\'"]([%w_.]+)[\'"]()' do
        annotationType(diffs, {}, localPos, varName, typeName)
    end

    ------------------- command -------------------
    
    --- ILuaCommandBuilder:handler
    for sender, args, pos in text:gmatch ':%s*command%s*%(%s*[\'"].+[\'"]%s*%).+:%s*handler%(%s*function%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*%)()' do
        diffs[#diffs+1] = {
            start  = pos,
            finish = pos - 1,
            text   = ('\n---@type org.bukkit.command.CommandSender\n%s = %s\n---@type table\n%s = %s\n'):format(sender, sender, args, args),
        }
    end

    --- registerRawCommand
    for sender, command, label, args, pos in text:gmatch ':registerRawCommand%(%s*[\'"].+[\'"]%s*,%s*function%s*%(%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*,%s*([%w_]+)%s*%)()' do
        diffs[#diffs+1] = {
            start  = pos,
            finish = pos - 1,
            text   = ([[

                ---@type org.bukkit.command.CommandSender
                %s = %s
                ---@type org.bukkit.command.Command
                %s = %s
                ---@type string
                %s = %s
                ---@type table
                %s = %s

            ]]):format(sender, sender, command, command, label, label, args, args),
        }
    end

    ------------------- event -------------------
    
    --- luaBukkit.env:onEvent
    for event, var, pos in text:gmatch ':onEvent%(%s*[\'"].+[\'"]%s*,%s*[\'"]([%w_.]+)[\'"]%s*,%s*function%s*%(%s*([%w_]+)%s*%)()' do
        diffs[#diffs+1] = {
            start  = pos,
            finish = pos - 1,
            text   = ([[

                ---@type %s
                %s = %s

            ]]):format(event, var, var),
        }
    end

    return diffs
end
