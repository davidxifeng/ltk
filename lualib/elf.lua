-- Sun 13:44 Jul 31

local assert = assert
local ipairs = ipairs
local type = type

local binary = require 'binary'

local read_buf    = binary.read_buf
local read_struct = binary.read_struct

local Elf32_Ehdr = {
}

local Elf64_Ehdr = {
  fmt = '{c16 u2 u2 u4 u8 u8 u8 u4 u2 u2 u2 u2 u2 u2}',
  [1]  = 'ident',       -- ident bytes       16 bytes
  [2]  = 'type',        -- file type         Elf64_Half
  [3]  = 'machine',     -- target machine    Elf64_Half
  [4]  = 'version',     -- file version      Elf64_Word
  [5]  = 'entry',       -- start address     Elf64_Addr
  [6]  = 'phoff',       -- phdr file offset  Elf64_Off
  [7]  = 'shoff',       -- shdr file offset  Elf64_Off
  [8]  = 'flags',       -- file flags        Elf64_Word
  [9]  = 'ehsize',      -- sizeof ehdr       Elf64_Half
  [10] = 'phentsize',   -- sizeof phdr       Elf64_Half
  [11] = 'phnum',       -- number phdrs      Elf64_Half
  [12] = 'shentsize',   -- sizeof shdr       Elf64_Half
  [13] = 'shnum',       -- number shdrs      Elf64_Half
  [14] = 'shstrndx',    -- shdr string index Elf64_Half
}

local ElfMethods = {}

--- 解析elf文件
function ElfMethods:parse()
  local buf = self[1]
  local mag, cls, enc  = read_buf(buf, '< c4 u1 u1')
  if mag ~= '\x7fELF' then return nil, 'bad elf magic' end
  self[2] = {} -- info table

  if cls == 1 then
    self[2].bit = '32-bit'
    self[2].header = read_struct(buf, Elf32_Ehdr)
  elseif cls == 2 then
    self[2].bit = '64-bit'
    self[2].header = read_struct(buf, Elf64_Ehdr)
  else
    return nil, 'unknown file class'
  end

  return self
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
