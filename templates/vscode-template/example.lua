------------ 1
-- auto annotate Player variable type as org.bukkit.entity.Player
local Player = luajava.bindClass("org.bukkit.entity.Player")
local aInventoryHolder = luajava.createProxy("org.bukkit.inventory.InventoryHolder", {
    getInventory = function () 
        return nil
    end
})

------------ 2
-- auto captured ObjectClass type and annotate same type for aObj variable
local Object = luajava.bindClass("java.lang.Object")
local ObjectClass = Object
local aObj = luajava.new(ObjectClass)

------------ 3
-- auto annotate event type for event handler function
local function handlePlayerQuitEvent(event)
    luaBukkit.log:info("Player " .. event:getPlayer():getName() .. " quit")
end
-- event listeners array
local listeners = {
    -- way 1, just define function 
    {
        event = "org.bukkit.event.player.PlayerJoinEvent",
        priority = "HIGH",
        handler = function(event)
            luaBukkit.log:info("event priority high")
        end
    },
    -- way 2, pass a variable to handler field
    {
        event = "org.bukkit.event.player.PlayerQuitEvent",
        priority = "HIGH",
        handler = handlePlayerQuitEvent
    }
}
luaBukkit.env:listenerBuilder():subscribes(listeners):build():register("MyListeners")

-- athor way to listen event
-- define function first
local function myPlayerQuitEvent(event)
    luaBukkit.log:info("Player " .. event:getPlayer():getName() .. " quit")
end
-- way 1, direct define function
luaBukkit.env:onEvent("MyPlayerJoinEvent", "org.bukkit.event.player.PlayerJoinEvent", function (event)
    luaBukkit.log:info("Player " .. event:getPlayer():getName() .. " join")
end)
-- way 2, use variable
luaBukkit.env:onEvent("MyPlayerJoinEvent", "org.bukkit.event.player.PlayerQuitEvent", myPlayerQuitEvent)

------------ 4
-- command
local function setHome(sender, command, label, args)
    return true
end

luaBukkit.env:registerRawCommand("setHome", setHome)
luaBukkit.env:registerRawCommand("home", function (a, b, c, d)
    return false
end)

local function setPlayerFly(player, args)
    player:sendMessage("you are fly!")
end

local commands = {
    -- auto detected command needPlayer or not then annotate sender param type to Player or CommandSender
    {
        command = "fly",
        needPlayer = true,
        handler = setPlayerFly
    },
    {
        command = "version",
        handler = function (sender, args) 
            sender:sendMessage("Lua 5.4")
        end
    }
}
local topCommandClass = luaBukkit.env:commandClassBuilder():commands(commands):build("TestCommand")
luaBukkit.env:registerCommand("TestCommand", {topCommandClass})