--[[
	header.lua
	class for the lua header
]]
local class = require "middleclass"
local bit = require "bit"
local byteStruct = require "byteStruct"

local Header = class("Header",byteStruct)

Header.static.format = {
	{"signature",1,4},
	{"version",0,1},
	{"format",0,1},
	{"endian",0,1},
	{"sizeof_int",0,1},
	{"sizeof_size_t",0,1},
	{"sizeof_instruction",0,1},
	{"sizeof_number",0,1},
	{"integral",0,1}
}

function Header:initialize(bytes)
	self.bytes = bytes
	self:getFormatedBytes(Header.format)
	self.version_str = tostring((self.version-self.version%16)/16).."."..self.version%16
	self:checkHeader()
end

function Header:checkHeader()
	if self.signature ~= "\27Lua" then
		error("Incorrect signature")
	end
	if self.version_str ~= _VERSION:sub(5) then
		error("Version mismatch")
	end
	if self.format ~= 0 then
		error("Unknown format")
	end
end

return Header
