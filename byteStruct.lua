--[[
	byteStruct.lua
	holds byteStruct because it is used by other files
]]
local class = require("middleclass")

local byteStruct = class("byteStruct")

local byteBuff = class("byteBuff")

function byteBuff:initialize(bytes,isbuff)
	self.bytes = bytes
	self.index = 1
end

function byteBuff:readBytes(size)
	if(self.index > #self.bytes) then error("byteBuff index out of bounds") end
	local bytes = self.bytes:sub(self.index,self.index+size-1)
	self.index = self.index + size
	return bytes
end

byteStruct.static.types = {
	INT = 0,
	CHAR = 1,
	LIST = 2,
}

function byteStruct.static.toNumber(bytes,e)
	local num = 0
	for i = 1,#bytes do
		local pow = e and #bytes - i or i - 1
		num = num+bytes:sub(i,i):byte()*256^pow
	end
	return num
end

function byteStruct.static.cast(bytes,type,e)
	if type == byteStruct.types.INT then
		return byteStruct.toNumber(bytes,e)
	elseif type == byteStruct.types.CHAR then
		return bytes
	end
end

function byteStruct:getBytes(length)
	return self.bytes:readBytes(length)
end

function byteStruct:getList(f)
	local tbl = {}
	local length = byteStruct.toNumber(self:getBytes(self.info.sizeof.size_t),not self.info.endian)
	for i=1,length do
		if type(f[3][1]) == "table" then -- Check if list of formats
			tbl[i]= self:getFormatedBytes(f[3],true)
		elseif f[3].subclasses then -- Check if class
			tbl[i] = f[3](self.bytes,self.info)
		else
			tbl[i] = self:getFormatedData(f[3])
		end
	end
	if f[3][2] == 1 then --Check if string
		tbl = table.concat(tbl)
	end
	return tbl
end

-- Format = {name,type,length}, {name,type=LIST,format}, {name,type=LIST,tableOfFormats} or {name,class}

function byteStruct:getFormatedData(f)
	if f[2] == byteStruct.types.LIST then
		return self:getList(f)
	elseif(type(f[2]) == "table" and f[2].subclasses) then -- Check if class
		return f[2](self.bytes)
	else
		return byteStruct.static.cast(self:getBytes(f[3]),f[2],true)
	end
end

function byteStruct:getFormatedBytes(format,ret)
	local data = ret and {} or nil
	for k,v in pairs(format) do
		if(data) then
			data[v[1]] = self:getFormatedData(v)
		else
			self[v[1]] = self:getFormatedData(v)
		end
	end
	return data
end

byteStruct.static.byteBuff = byteBuff

return byteStruct
