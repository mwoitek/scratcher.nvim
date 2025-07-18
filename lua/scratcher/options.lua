---@alias scratcher.Position "above"|"below"|"left"|"right"|"float"
---@alias scratcher.Size { width: number, height: number }

---@class scratcher.Opts
---@field position scratcher.Position
---@field size scratcher.Size
---@field start_in_insert boolean
local Opts = {
  position = "below",
  size = { width = 0.5, height = 0.33 },
  start_in_insert = false,
}
Opts.__index = Opts

---@param opts table?
---@return scratcher.Opts
function Opts.new(opts)
  vim.validate("opts", opts, "table", true, "options table or nil")
  opts = vim.tbl_deep_extend("force", Opts, opts or {})
  return setmetatable(opts, Opts)
end

return Opts
