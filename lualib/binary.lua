local assert = assert

local buffer = require 'buffer'
local read_buf = buffer.read

local M = {}

M.read_buf = read_buf

function M.read_struct(buf, info, fmt)
  local res = read_buf(buf, assert(info.fmt or fmt))
  assert(# res == # info)
  local r = {}
  for i, v in ipairs(info) do r[v] = res[i] end
  return r
end

return M
