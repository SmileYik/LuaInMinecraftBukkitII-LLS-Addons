

local a = luajava.bindClass("org.bukkit.Bukkaaitaaa") f = luajava.bindClass("org.bukkit.Bukkaaitaaa") 
f = luajava.bindClass("org.bukkit.Bukkaaitaaa") 
local b = luajava.newInstance("org.bukkit.Abc")
local c = luajava.createProxy("abc.def", {})
local d = luajava.new(a, 1, 2, 3)
local e = luajava.new(b)

local f = {
    a = luajava.bindClass("abc"),
    b = luajava.createProxy("abc.def", {}),
    c = luajava.newInstance("org.bukkit.Abc")
}

local e = luajava.new(b)


-- build a command class
local topCommandClass = luaBukkit.env:commandClassBuilder()
    :commands(commands)
    :command("say")
        :args({"msg"})
        :description("say something")
        :handler(function(sender, args)
            sender:sendMessage(args[1])
        end)
    :aliases({"tc", "testc"})
    :build("TestCommand")



-- register home command
luaBukkit.env:registerRawCommand("home2", function (sender, command, label, args)
    if not luajava.class2Obj(Player):isInstance(sender) then
        sender:sendMessage("Only player can use this command!")
        return false
    end
    local homes = readJsonFile(sender:getName() .. ".json")
    if not homes.home then
        sender:sendMessage("You have not set a home yet")
        return true
    end
    local loc = tableToLocation(homes.home)
    sender:teleport(loc)
    return true
end) 

luaBukkit.env:onEvent("id", "abc.Abc", function (e) 
end)