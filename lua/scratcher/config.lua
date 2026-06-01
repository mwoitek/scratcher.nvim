local Config = {
  autosave = true,
  window_strategy = "split",
}
Config.__index = Config

function Config:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

function Config:get(name)
  local value = vim.g["scratcher_" .. name]
  if value ~= nil then return value end
  return self[name]
end

function Config:setup(opts)
  for k, v in pairs(opts) do
    vim.g["scratcher_" .. k] = v
  end
end

return Config:new()
