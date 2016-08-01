-- Sun 13:44 Jul 31

local assert = assert
local ipairs = ipairs
local type = type

local buffer = require 'buffer'

local reader = buffer.read


local ElfMethods = {
  elf32_hdr = '',
  elf64_hdr = '',
}

--- 解析elf文件
function ElfMethods:parse()
  local buf = self[1]
  local mag, cls, enc  = reader(buf, '< c4 u1 u1')
  if mag ~= '\x7fELF' then return nil end
  self[2] = {} -- info table
  self:setFileClass(cls):setDataEncoding(enc):parseHeader()

  return self
end

function ElfMethods:setDataEncoding(enc)
  if enc == 1 then
    self[2].endian = 'LSB'
  elseif enc == 2 then
    self[2].endian = 'MSB'
    assert(false, 'TODO big endian data encoding support')
  else
    assert(false, 'bad data encoding')
  end
  return self
end

function ElfMethods:setFileClass(cls)
  if cls == 1 then
    self[2].bit = '32-bit'
  elseif cls == 2 then
    self[2].bit = '64-bit'
  else
    assert(false, 'bad file class')
  end
  return self
end

function ElfMethods:parseHeader()
end

function ElfMethods:info()
  return self[2]
end

local M = {}
-- 先两种类型分开处理，后续能统一处理的话再合并
local elf_mt = { __index = ElfMethods }

function M.new(elf_file)
  local fc = io.read_file(elf_file)
  if fc and # fc > 128 then -- XXX min size of valid elf
    return setmetatable({fc}, elf_mt):parse()
  end
end

return M
