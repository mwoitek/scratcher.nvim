local M = {}

---@param x any
---@return boolean
function M.is_positive(x) return type(x) == "number" and x > 0 end

---@param x any
---@return boolean
function M.is_valid_position(x)
  return type(x) == "string" and vim.tbl_contains({ "above", "below", "left", "right", "float" }, x)
end

return M
