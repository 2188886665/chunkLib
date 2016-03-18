if (not require) and dofile then
	require = function(a)
		dofile(a..".lua")
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

function func()
  print("hi")
end

local str = "\27\76\117\97\81\0\0\4\4\4\8\0\0\0\0\0\0\0\0\1\0\0\0\3\0\0\0\2\0\0\0\4\0\0\0\5\0\0\64\65\1\0\64\28\0\128\0\30\0\0\0\2\4\0\0\0\6\112\114\105\110\116\0\4\0\0\0\3\104\105\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"--string.dump(func)

local test = str:gsub("\4%z%z%z\5","\3\0\0\0\5"):gsub("\30%z\128%z","")

local chunk = Chunk(str)
print(chunk.func.name)
for k,v in pairs(chunk.func.instructions) do
	print(v)
end
