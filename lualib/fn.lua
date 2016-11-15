--- utils library function
--
-- last modified: Tue 15:44 Nov 15
-- created: Thu 16:08 Sep 01
-- @license MIT
-- @author davidxifeng@gmail.com
-- @module fn

local M = {}

local table  = table
local pairs  = pairs
local ipairs = ipairs

--- @see: http://hackage.haskell.org/package/base-4.9.0.0/docs/Data-List.html#v:any
function M.any(cb, ...)--{{
  local list = table.pack(...)
  for i = 1, list.n do
    if cb(list[i]) then
      return true
    end
  end
  return false
end--}}

function M.all(cb, ...)--{{
  local list = table.pack(...)
  for i = 1, list.n do
    if not cb(list[i]) then
      return false
    end
  end
  return true
end--}}

function M.build_map(tbl)--{{
  local r = {}
  for k, v in pairs(tbl) do
    r[v] = k
  end
  return r
end--}}

function M.build_dict(tbl)--{{
  local r = {}
  for i = 1, # tbl do
    r[tbl[i]] = true
  end
  return r
end--}}

function M.clear_table(tb)--{{
  for k, v in pairs(tb) do
    tb[k] = nil
  end
end--}}

function M.array_foreach(tb, f, ...)--{{
  for i = 1, #tb do
    f(tb[i], i, ...)
  end
end--}}

function M.foreach_kv(tb, f, ...)--{{
  for k, v in pairs(tb) do
    f(k, v, ...)
  end
end--}}

function M.foreach_v(tb, f, ...)--{{
  for _, v in pairs(tb) do
    f(v, ...)
  end
end--}}

function M.dict_size(tb)--{{
  local n = 0
  for _, _ in pairs(tb) do
    n = n + 1
  end
  return n
end--}}

function M.elem(array, e)--{{
  for i = 1, #array do
    if e == array[i] then
      return true
    end
  end
  return false
end--}}

return M

-- vim: tabstop=2 softtabstop=2 shiftwidth=2
-- vim: fdm=marker foldmarker={{,}}
