local assert = assert

local buffer = require 'buffer'
local read_buf = buffer.read

local M = {}

local function read_struct(buf, info, fmt)
  local res = read_buf(buf, assert(fmt or info.fmt))
  assert(# res == # info)
  local r = {}
  for i, v in ipairs(info) do r[v] = res[i] end
  return r
end

M.read_buf = read_buf
M.read_struct = read_struct

function M.read_array(buf, offset, size, num, info, fmt)
  offset = offset - size
  local fmt = '+%d %s'
  local r = {}
  for i = 1, num do
    r[i] = read_struct(buf, info, fmt:format(offset + i * size, info.fmt))
  end
  return r
end

return M
