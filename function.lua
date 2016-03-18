--[[
	function.lua
	Holds the function prototype class
]]
local class = require "middleclass"
local bit = require "bit"
local byteStruct = require "byteStruct"
local Instruction = require "instruction"
local Constant,Local = unpack(require "other")
local Function = class("Function",byteStruct)

Function.static.localsFormat = {
	{"name",2,{nil,1,1}},
	{"scope_start",0,4},
	{"scope_end",0,4}
}

function Function:getFormat()
	return {
	{"name",2,{nil,1,1}},
	{"line_defined",0,self.info.sizeof.int},
	{"last_defined",0,4},
	{"num_upvalues",0,1},
	{"num_params",0,1},
	{"is_vararg",0,1},
	{"stack_size",0,1},
	{"instructions",2,Instruction},
	{"constants",2,Constant},
	{"functions",2,Function},
	{"sourcelinepos",2,{nil,0,4}},
	{"locals",2,Local},
	{"upvals",2,{"",2,{"",1,1}}},
}
end

--Constructor, provide bytes from start of function to the end of the dump

function Function:initialize(bytes,info)
	self.info = info
	self.bytes = bytes
	self:getFormatedBytes(self:getFormat())
end

return Function
