local module = {}

function module.split(str, sep)
  local t = {}
  if not str then
    return t
  end

  for s in module.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(t, s)
  end

  return t
end

function module.trim(s, trimmed)
  local patt = module.format("^%s*(.-)%s*$", trimmed, trimmed)
  -- wezterm.log_info(patt)
  return s:match(patt)
end

return module
