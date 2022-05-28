local DEFAULT_OPTS = {
  position = "bottom",
  height = 12,
  width = 36,
}

local M = {}

M.get_opts = function(opts)
  local _opts = {}
  for k, v in pairs(DEFAULT_OPTS) do
    _opts[k] = opts[k] and opts[k] or v
  end
  return _opts
end

return M
