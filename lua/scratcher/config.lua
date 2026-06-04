local Config = {
  autosave = true,
  extension = "txt",
  storage_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "scratcher"),
  window_strategy = "split",
  _PREFIX = "scratcher_",
}
Config.__index = Config

function Config:new(o)
  o = o or {}
  return setmetatable(o, self)
end

function Config:get(name)
  local value = vim.g[self._PREFIX .. name]
  if value ~= nil then return value end

  local default_value = self[name]
  if default_value ~= nil then return default_value end

  local err = string.format("Failed to assign value to configuration variable: %s", name)
  error(err)
end

function Config:setup(opts)
  opts = opts or {}
  for k, v in pairs(opts) do
    vim.g[self._PREFIX .. k] = v
  end
end

return Config:new()
