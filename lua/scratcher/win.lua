local M = {}

local valid = require "scratcher.validation"

---@param width number
---@return integer
function M.compute_width(width)
  vim.validate("width", width, valid.is_positive, "positive number")
  local factor = math.floor(width) == width and 1 or vim.o.columns
  return math.min(math.floor(width * factor), vim.o.columns - 1)
end

---@param height number
---@return integer
function M.compute_height(height)
  vim.validate("height", height, valid.is_positive, "positive number")
  local factor = math.floor(height) == height and 1 or vim.o.lines
  return math.min(math.floor(height * factor), vim.o.lines - 1)
end

---@param position scratcher.Position
---@param size scratcher.Size
---@return vim.api.keyset.win_config
function M.get_win_config(position, size)
  vim.validate("position", position, valid.is_valid_position, "valid window position")

  local config = {}

  -- TODO

  return config
end

return M
