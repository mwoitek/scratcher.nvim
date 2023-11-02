local M = {}

---@param buf number?
---@return boolean
function M.is_buf_empty(buf)
  vim.validate {
    buf = {
      buf,
      function(b) return type(b) == "number" and vim.api.nvim_buf_is_loaded(b) end,
      "invalid buffer number",
    },
  }

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)

  for _, line in ipairs(lines) do
    if vim.trim(line):len() > 0 then return false end
  end

  return true
end

---@param x any
---@return boolean
function M.is_integer(x)
  if type(x) ~= "number" then return false end
  local i, _ = math.modf(x)
  return i == x
end

return M
