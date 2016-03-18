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

function func()
  print("hi")
end

local d = string.dump ( loadstring ( [[return 523123.123145345]] ) )
local s , e = d:find ( "\3%z%z%z\54\208\25\126\204\237\31\65" )

for k,v in pairs(Chunk(d).func.constants) do
	print(v.byteval:byte(1,8))
end
