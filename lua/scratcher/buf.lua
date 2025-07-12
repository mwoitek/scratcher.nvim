local M = {}

local valid = require "scratcher.validation"

---@param buf integer?
function M.clear(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  vim.api.nvim_buf_set_lines(buf or 0, 0, -1, true, {})
end

---@param buf integer?
---@return boolean
function M.is_empty(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  local lines = vim.api.nvim_buf_get_lines(buf or 0, 0, -1, true)
  return vim.iter(lines):all(function(l) return vim.trim(l):len() == 0 end)
end

return M
