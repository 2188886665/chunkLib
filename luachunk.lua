if (not require) and dofile then
	require = function(a)
		return dofile(shell.dir().."/"..a..".lua")
	end
end

local class = require "middleclass"
local byteStruct = require "byteStruct"
local Header = require "header"
local Function = require "function"

local Chunk = class("Chunk")

function Chunk:initialize(dump)
	self.bytes = byteStruct.byteBuff(dump)
	self.header = Header(self.bytes)
	local info = {}
	info.endian = self.header.endian == 1
	info.sizeof = {size_t=self.header.sizeof_size_t,int = self.header.sizeof_int}
	self.func = Function(self.bytes,info)
end

local code = [[
	local a = 2
	function b(c)
		a=a+c
	end
]]

local function decompFunc(x)
  for i = x,x,0 do
	return i
  end
end

local str = string.dump(decompFunc)

local f = io.open("sample.lua","wb")
f:write(str)
f:close()

for k,v in pairs(Chunk(str).func.instructions) do
	print(v)
end
