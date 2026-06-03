local Config = {
  autosave = true,
  storage_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "scratcher"),
  window_strategy = "split",
}
Config.__index = Config

function Config:new(o)
  o = o or {}
  return setmetatable(o, self)
end

local VARIABLE_PREFIX = "scratcher_"

function Config:get(name)
  local value = vim.g[VARIABLE_PREFIX .. name]
  if value ~= nil then return value end
  return self[name]
end

function Config.setup(opts)
  opts = opts or {}
  for k, v in pairs(opts) do
    vim.g[VARIABLE_PREFIX .. k] = v
  end
end

return Config:new()
