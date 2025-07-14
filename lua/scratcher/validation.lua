local M = {}

---@param x any
---@return boolean
function M.is_positive(x) return type(x) == "number" and x > 0 end

---@param x any
---@return boolean
function M.is_positive_integer(x) return M.is_positive(x) and math.floor(x) == x end

---@param x any
---@return boolean
function M.is_valid_buffer(x) return type(x) == "number" and vim.api.nvim_buf_is_loaded(x) end

---@param x any
---@param type_ "directory"|"file"
---@return boolean
local function is_valid_path(x, type_)
  if type(x) ~= "string" then return false end
  ---@cast x string
  local stat = vim.uv.fs_stat(vim.fs.normalize(x))
  return type(stat) == "table" and stat.type == type_
end

---@param x any
---@return boolean
function M.is_valid_directory(x) return is_valid_path(x, "directory") end

---@param x any
---@return boolean
function M.is_valid_file(x) return is_valid_path(x, "file") end

---@param x any
---@return boolean
function M.is_valid_position(x)
  return type(x) == "string" and vim.tbl_contains({ "above", "below", "left", "right", "float" }, x)
end

return M
