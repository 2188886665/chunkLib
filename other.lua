--[[
	others.lua
	Holds Constant class and Locals class
]]
local float = require "floats"
local byteStruct = require "byteStruct"
local class = require "middleclass"

local Constant = class("Constant",byteStruct)

function Constant:initialize(bytes,info)
	self.bytes = bytes
	self.info = info
	self.type = self:getBytes(1):byte()
	if self.type == 0 then
		return
	elseif	self.type == 1 then
		self.value = self:getBytes(1):byte()
	elseif self.type == 3 then
		self.byteval = self:getBytes(8)
		self.value = float.read_double(self.byteval,true)
	else
		self.value = self:getFormatedData({nil,2,{nil,1,1}})
	end
end

local Local = class("Local",byteStruct)

function Local:initialize(bytes,info)
	self.bytes = bytes
	self.info = info
	self.name = self:getFormatedData({nil,2,{nil,1,1}})
	self.scope_start = byteStruct.toNumber(self:getBytes(4))
	self.scope_end = byteStruct.toNumber(self:getBytes(4))
end

return {Constant,Local}
