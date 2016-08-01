local io = require 'iox'
local string = require 'stringx'
local M = _ENV

local inspect = require 'inspect'
local print = print

function M.show(v)
  print(inspect(v))
end

return M
