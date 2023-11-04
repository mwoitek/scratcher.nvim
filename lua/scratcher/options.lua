local valid = require "scratcher.validation"

---@alias auto_hide { enable: boolean, timeout: number }

---@class Options
---@field position string
---@field width number
---@field height number
---@field start_in_insert boolean
---@field auto_hide auto_hide
local Options = {
  position = "top",
  width = 0.35,
  height = 0.2,
  start_in_insert = false,
  auto_hide = {
    enable = false,
    timeout = 10, -- minutes
  },
}

---@param raw_opts any
---@return Options
function Options:new(raw_opts)
  local opts = {}
  setmetatable(opts, { __index = self })

  if not valid.is_dict(raw_opts) then return opts end

  for _, opt in ipairs { "position", "width", "height" } do
    opts[opt] = valid["is_valid_" .. opt](raw_opts[opt]) and raw_opts[opt] or nil
  end

  if type(raw_opts.start_in_insert) == "boolean" then opts.start_in_insert = raw_opts.start_in_insert end

  local raw_ah = raw_opts.auto_hide
  if valid.is_dict(raw_ah) then
    local ah = {}
    setmetatable(ah, { __index = self.auto_hide })

    if type(raw_ah.enable) == "boolean" then ah.enable = raw_ah.enable end
    if valid.is_non_negative(raw_ah.timeout) then ah.timeout = raw_ah.timeout end

    opts.auto_hide = not vim.tbl_isempty(ah) and ah or nil
  end

  return opts
end

---@alias dimension "width" | "height"

---@param dim dimension
---@return number
function Options:get_dimension(dim)
  vim.validate {
    dim = {
      dim,
      function(d) return d == "width" or d == "height" end,
      "width or height",
    },
  }

  local val = self[dim]
  ---@cast val number

  if require("scratcher.utils").is_integer(val) then return val end

  local max_val = dim == "width" and vim.o.columns or vim.o.lines
  return math.floor(val * max_val)
end

---@return string
function Options:split_cmd()
  local pos = self.position
  if pos == "bottom" or pos == "top" then
    return string.format("%s %d split", pos == "bottom" and "bel" or "abo", self:get_dimension "height")
  end
  return string.format("%s %d vsplit", pos == "right" and "bel" or "abo", self:get_dimension "width")
end

return Options
