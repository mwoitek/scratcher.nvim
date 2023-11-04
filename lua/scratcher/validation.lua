local is_integer = require("scratcher.utils").is_integer

local M = {}

---@param x any
---@return boolean
function M.is_dict(x) return type(x) == "table" and (vim.tbl_isempty(x) or not vim.tbl_islist(x)) end

---@param x any
---@return boolean
function M.is_non_negative(x) return type(x) == "number" and x >= 0 end

---@param x any
---@return boolean
function M.is_valid_position(x)
  return type(x) == "string" and vim.tbl_contains({ "bottom", "top", "left", "right" }, x)
end

---@param x any
---@return boolean
function M.is_valid_width(x)
  if type(x) ~= "number" then return false end
  return x > 0 and x < (is_integer(x) and vim.o.columns or 1)
end

---@param x any
---@return boolean
function M.is_valid_height(x)
  if type(x) ~= "number" then return false end
  return x > 0 and x < (is_integer(x) and vim.o.lines or 1)
end

return M
