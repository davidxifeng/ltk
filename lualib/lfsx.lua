-- utility function based on lua-filesystem

local LFS = require 'lfs'

local function walk_dir(dir, cb)
  for file, dir_obj in LFS.dir(dir) do
    if file ~= '.' and file ~= '..' then
      local ip = dir .. '/' .. file
      local attr = LFS.attributes(ip)
      if attr.mode == 'file' then
        cb(ip, attr)
      end
    end
  end
end

LFS.walk_dir = walk_dir

local function walk_tree(dir, cb)
  for file, dir_obj in LFS.dir(dir) do
    if file ~= '.' and file ~= '..' then
      local ip = dir .. '/' .. file
      local attr = LFS.attributes(ip)
      if attr.mode == 'directory' then
        walk_tree(ip, cb)
      elseif attr.mode == 'file' then
        cb(ip, attr)
      end
    end
  end
end

LFS.walk_tree = walk_tree

return LFS
