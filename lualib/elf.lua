-- Sun 13:44 Jul 31

local assert = assert
local ipairs = ipairs
local type = type

local binary = require 'binary'

local read_buf    = binary.read_buf
local read_struct = binary.read_struct
local read_array  = binary.read_array


local Elf32_Ehdr = {
}

local Elf64_Ehdr = {
  fmt = '< {c16 u2 u2 u4 u8 u8 u8 u4 u2 u2 u2 u2 u2 u2}',
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

local Elf64_Shdr = {
  fmt = '< {u4 u4 u8 u8 u8 u8 u4 u4 u8 u8}',
  [1]  = 'sh_name',      -- Elf64_Word  section name
  [2]  = 'sh_type',      -- Elf64_Word  SHT_...
  [3]  = 'sh_flags',     -- Elf64_Xword SHF_...
  [4]  = 'sh_addr',      -- Elf64_Addr  virtual address
  [5]  = 'sh_offset',    -- Elf64_Off   file offset
  [6]  = 'sh_size',      -- Elf64_Xword section size
  [7]  = 'sh_link',      -- Elf64_Word  misc info
  [8]  = 'sh_info',      -- Elf64_Word  misc info
  [9]  = 'sh_addralign', -- Elf64_Xword memory alignment
  [10] = 'sh_entsize',   -- Elf64_Xword entry size if table
}

local Elf64_Phdr = {
  fmt = '< {u4 u4 u8 u8 u8 u8 u8 u8}',
  [1] = 'p_type',   -- Elf64_Word  entry type
  [2] = 'p_flags',  -- Elf64_Word  entry flags
  [3] = 'p_offset', -- Elf64_Off   file offset
  [4] = 'p_vaddr',  -- Elf64_Addr  virtual address
  [5] = 'p_paddr',  -- Elf64_Addr  physical address
  [6] = 'p_filesz', -- Elf64_Xword file size
  [7] = 'p_memsz',  -- Elf64_Xword memory size
  [8] = 'p_align',  -- Elf64_Xword memory/file alignment
}

local ElfMethods = {}

--- 解析elf文件
function ElfMethods:parse()
  local buf = self[1]
  local mag, cls, enc  = read_buf(buf, '< c4 u1 u1')
  if mag ~= '\x7fELF' then return nil, 'bad elf magic' end
  self[2] = {} -- info table

  if     cls == 1 then return self:parse_elf32(buf)
  elseif cls == 2 then return self:parse_elf64(buf)
  else return nil, 'unknown file class'
  end
end

function ElfMethods:parse_elf32(buf)
  local info = self[2]
  info.bit = '32-bit'
  info.header = read_struct(buf, Elf32_Ehdr)
  return self
end

function ElfMethods:parse_elf64(buf)
  local info = self[2]
  info.bit = '64-bit'

  local ehdr = read_struct(buf, Elf64_Ehdr)
  info.header = ehdr

  local shdr = read_array(buf, ehdr.shoff, ehdr.shentsize, ehdr.shnum, Elf64_Shdr)
  info.shdr = shdr

  local sections = {}
  for i, v in ipairs(shdr) do
    -- SHT_NOBITS    8
    if v.sh_type ~= 8 then
      local t = v.sh_offset + 1
      sections[i] = buf:sub(t, t + v.sh_size) -- TODO buffer usertype
    else
      sections[i] = ''
    end
  end
  info.sections = sections

  -- SHN_UNDEF 0
  if ehdr.shstrndx ~= 0 then
    local str_tab = sections[ehdr.shstrndx + 1]
    for _, v in ipairs(shdr) do
      v.sh_name = read_buf(str_tab, ('+%d s'):format(v.sh_name))
    end
  end

  local phdr = read_array(buf, ehdr.phoff, ehdr.phentsize, ehdr.phnum, Elf64_Phdr)
  info.phdr = phdr

  return self
end

function ElfMethods:info()
  local info = self[2]
  --info.shdr = nil
  info.sections = nil
  return info
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
