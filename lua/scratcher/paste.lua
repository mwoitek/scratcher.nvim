---@param s string
---@return string
local function trim(s) return s:match "^%s*(.-)%s*$" end

---@param buf number
---@return boolean
local function is_buf_empty(buf)
  if vim.api.nvim_buf_line_count(buf) > 1 then return false end
  local line = vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
  local trimmed_line = trim(line)
  return trimmed_line:len() == 0
end

---@return number[]
local function get_range()
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "ntx", false)

  local _, start_row, start_col, _ = unpack(vim.fn.getcharpos "'<")
  local _, end_row, end_col, _ = unpack(vim.fn.getcharpos "'>")

  start_row = start_row - 1
  start_col = start_col - 1
  end_row = end_row - 1

  return { start_row, start_col, end_row, end_col }
end

local M = {}

---@param buf number
---@param mode string
---@return string[]
function M.get_text(buf, mode)
  local start_row, start_col, end_row, end_col = unpack(get_range())
  local text = vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})

  if mode:lower() == "v" then return text end

  -- TODO: handle visual block
  return { "" }
end

---@param buf number
---@param text string[]
---@param count number
function M.paste(buf, text, count)
  for _ = 1, count do
    local start_line = is_buf_empty(buf) and 0 or -1
    vim.api.nvim_buf_set_lines(buf, start_line, -1, true, text)
  end
end

return M
