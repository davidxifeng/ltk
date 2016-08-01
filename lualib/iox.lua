local io = io

function io.read_file(filename)
  local file, err = io.open(filename, 'rb')
  if file then
    local r = file:read 'a'
    file:close()
    return r
  else
    return nil, err
  end
end

function io.write_file(filename, ...)
  local file, err = io.open(filename, 'wb')
  if file then
    file:write(...):close()
    return true
  else
    return nil, err
  end
end

return io
