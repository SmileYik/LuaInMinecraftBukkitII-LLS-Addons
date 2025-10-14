---@meta
---@class org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.LuaIOHelper: java.lang.Object
local LuaIOHelper = {}

---将输入流传输至输出流. 传输完成后会关闭流.
---@public
---@param inputStream org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.InputStream 输入流
---@param outputStream org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.OutputStream 输出流
---@param bufferSize number 缓冲区大小
---@return nil 
function LuaIOHelper:transferAndClose(inputStream, outputStream, bufferSize) end

---将输入流传输至输出流. 传输完成后不会关闭流, 需要手动关闭.
---@public
---@param inputStream org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.InputStream 输入流
---@param outputStream org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.OutputStream 输出流
---@param bufferSize number 缓冲区大小
---@return nil 
function LuaIOHelper:transfer(inputStream, outputStream, bufferSize) end

---从输入流中读取所有字节. 不会关闭输入流
---@public
---@param inputStream org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.InputStream 输入流
---@param bufferSize number 缓冲大小
---@return number[] 读入的所有字节
function LuaIOHelper:readBytes(inputStream, bufferSize) end

---写入所有字节到输出流中. 不会关闭流.
---@public
---@param outputStream org.eu.smileyik.luaInMinecraftBukkitII.api.lua.luaState.OutputStream 输出流
---@param bytes number[] 要写出的字节
---@return nil 
function LuaIOHelper:writeBytes(outputStream, bytes) end

return LuaIOHelper