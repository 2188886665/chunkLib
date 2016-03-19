--[[
	instruction.lua by Gorzoid
	This will probably use some GPL liscence meh
	This holds the class for the instruction, giving access to the opcode,
	the args and a simple __tostring for debuging purposes.
]]
local class = require "middleclass"
local bit = bit32 or require "bit"
bit.lshift = bit.lshift or bit.blshift
bit.rshift = bit.rshift or bit.rlshift
local bitBuff = class("bitBuff")

--Gets a number of bits starting from index

function bitBuff:readBits(length)
	local num = 2^(self.index+length-1)-1
	self.index = self.index+length
	return bit.rshift(bit.band(self.value,num),self.index-length-1)
end


function bitBuff.static.numToAscii(num)
	local str = ""
	while(num > 0) do
		str = string.char(num%256)..str
		num = bit.rshift(num,8)
	end
	return str
end

function bitBuff.static.asciiToNum(str,e)
	local i = e and 0 or #str - 1
	local int = 0;
	for c in str:gmatch(".") do
		int = int+string.byte(c)*256^i
		i = i+ (e and 1 or -1)
	end
	return int
end

function bitBuff.static.sign(int,bits)
	local half = 2^bits/2 -1
	return int - half
end

local Instruction = class("Instruction",bitBuff)

Instruction.static.instructions = {
	{"OP_MOVE",1},
	{"OP_LOADK",2},
	{"OP_LOADBOOL",1},
	{"OP_LOADNIL",1},
	{"OP_GETUPVAL",1},
	{"OP_GETGLOBAL",2},
	{"OP_GETTABLE",1},
	{"OP_SETGLOBAL",2},
	{"OP_SETUPVAL",1},
	{"OP_SETTABLE",1},
	{"OP_NEWTABLE",1},
	{"OP_SELF",1},
	{"OP_ADD",1},
	{"OP_SUB",1},
	{"OP_MUL",1},
	{"OP_DIV",1},
	{"OP_MOD",1},
	{"OP_POW",1},
	{"OP_UNM",1},
	{"OP_NOT",1},
	{"OP_LEN",1},
	{"OP_CONCAT",1},
	{"OP_JMP",3},
	{"OP_EQ",1},
	{"OP_LT",1},
	{"OP_LE",1},
	{"OP_TEST",1},
	{"OP_TESTSET",1},
	{"OP_CALL",1},
	{"OP_TAILCALL",1},
	{"OP_RETURN",1},
	{"OP_FORLOOP",3},
	{"OP_FORPREP",3},
	{"OP_TFORLOOP",1},
	{"OP_SETLIST",1},
	{"OP_CLOSE",1},
	{"OP_CLOSURE",2},
	{"OP_VARARG",1},
}

Instruction.static.formats = {
	{id = "iABC",a={8,false},b={9,false},c={9,false}},
	{id = "iABx",a={8,false},b={18,false}},
	{id = "iAsBx",a={8,false},b={18,true}}
}


function Instruction.static.getInstruction(id)
	if id+1 > #Instruction.instructions then error("Instructions index out of bounds") end
	return Instruction.instructions[id+1]
end

--Returns the arguments of instruction using the given format

function Instruction:getArgs()
	local args = {}
	for k,v in pairs(self.format) do
		if k ~= "id" then
			args[k] = v[2] and bitBuff.static.sign(self:readBits(v[1],self.info.endian),v[1]) or self:readBits(v[1],self.info.endian)
		end
	end
	return args
end
local hex = "0123456789ABCDEF"
local function toHexString(num,bytes)
	local str = ""
	for i = 1,bytes*2 do
		str = hex:sub(num%16+1,num%16+1)..str
		num = math.floor(num/16)
	end
	return str
end

--To String for printing

function Instruction:__tostring()
	local opcode = Instruction.getInstruction(self.opcode)[1]
	local args = self.args.a .."\t".. self.args.b .."\t".. (self.args.c or "")
	return toHexString(self.value,4).."   "..opcode..(#opcode and "\t" or "\t\t")..args
end

--Constructor

function Instruction:initialize(bytes, info)
	self.index = 1
	self.info = info
	self.value = bitBuff.static.asciiToNum(bytes:readBytes(4),info.endian)
	self.opcode = self:readBits(6)
	self.format = Instruction.formats[Instruction.getInstruction(self.opcode)[2]]
	self.args = self:getArgs()
end

return Instruction
