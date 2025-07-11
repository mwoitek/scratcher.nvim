local M = {}

local floor = math.floor
local min = math.min
local validate = vim.validate

---@param width number
---@return integer
function M.compute_width(width)
  validate("width", width, function(x) return type(x) == "number" and x > 0 end, "positive number")
  local factor = floor(width) == width and 1 or vim.o.columns
  return min(floor(width * factor), vim.o.columns - 1)
end

---@param height number
---@return integer
function M.compute_height(height)
  validate("height", height, function(x) return type(x) == "number" and x > 0 end, "positive number")
  local factor = floor(height) == height and 1 or vim.o.lines
  return min(floor(height * factor), vim.o.lines - 1)
end

return M
