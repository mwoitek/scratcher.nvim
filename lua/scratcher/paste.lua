local CTRL_V = vim.api.nvim_replace_termcodes("<C-V>", true, false, true)
local ESC = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

---@return number[]
local function get_range_from_selection()
  vim.api.nvim_feedkeys(ESC, "ntx", false)
  local _, start_row, start_col, _ = unpack(vim.fn.getcharpos "'<")
  local _, end_row, end_col, _ = unpack(vim.fn.getcharpos "'>")
  return { start_row - 1, start_col - 1, end_row - 1, end_col }
end

local M = {}

---@param buf number
---@param mode string
---@return string[]?
function M.get_text_from_selection(buf, mode)
  if mode:lower() ~= "v" and mode ~= CTRL_V then return nil end

  local start_row, start_col, end_row, end_col = unpack(get_range_from_selection())
  local text = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})

  if mode:lower() == "v" then return text end
  return vim.tbl_map(function(l) return l:sub(start_col + 1, end_col) end, text)
end

---@param buf number
---@param text string[]?
---@param count number
function M.paste(buf, text, count)
  if not text then return end
  count = count > 0 and count or 1

  local start_line = require("scratcher.utils").is_buf_empty(buf) and 0 or -1
  vim.api.nvim_buf_set_lines(buf, start_line, -1, true, text)
  if count == 1 then return end

  for _ = 2, count do
    vim.api.nvim_buf_set_lines(buf, -1, -1, true, text)
  end
end

return M
