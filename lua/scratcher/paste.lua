local api = vim.api

local CTRL_V = api.nvim_replace_termcodes("<C-V>", true, false, true)
local ESC = api.nvim_replace_termcodes("<Esc>", true, false, true)

---@param motion_type string
---@return number[]?
local function get_range_from_motion(motion_type)
  if motion_type == "block" then return nil end

  local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
  local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))

  if motion_type == "line" then return { start_row - 1, end_row } end
  return { start_row - 1, start_col, end_row - 1, end_col + 1 }
end

---@return number[]
local function get_range_from_selection()
  api.nvim_feedkeys(ESC, "ntx", false)
  local _, start_row, start_col, _ = unpack(vim.fn.getcharpos "'<")
  local _, end_row, end_col, _ = unpack(vim.fn.getcharpos "'>")
  return { start_row - 1, start_col - 1, end_row - 1, end_col }
end

local M = {}

---@param mode string
---@return boolean
function M.is_mode_allowed(mode) return vim.tbl_contains({ "n", "v", "V", CTRL_V }, mode) end

---@param motion_type string
---@param delete boolean?
---@return string[]?
function M.get_text_from_motion(motion_type, delete)
  local range = get_range_from_motion(motion_type)

  if not range then return nil end

  if #range == 2 then
    local start_row, end_row = unpack(range)
    local text = api.nvim_buf_get_lines(0, start_row, end_row, true)
    if delete and not vim.bo[0].readonly then api.nvim_buf_set_lines(0, start_row, end_row, true, {}) end
    return text
  end

  local start_row, start_col, end_row, end_col = unpack(range)
  local text = api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
  if delete and not vim.bo[0].readonly then
    api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, {})
  end
  return text
end

---@param mode string
---@param delete boolean?
---@return string[]?
function M.get_text_from_selection(mode, delete)
  if mode:lower() ~= "v" and mode ~= CTRL_V then return nil end

  local start_row, start_col, end_row, end_col = unpack(get_range_from_selection())
  local text = api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})

  if mode:lower() == "v" then
    if delete and not vim.bo[0].readonly then
      api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, {})
    end
    return text
  end

  if delete and not vim.bo[0].readonly then
    for row = start_row, end_row do
      api.nvim_buf_set_text(0, row, start_col, row, end_col, {})
    end
  end
  return vim.tbl_map(function(l) return l:sub(start_col + 1, end_col) end, text)
end

---@param buf number?
---@param text string[]?
---@param count number
function M.paste(buf, text, count)
  if not (buf and text) then return end
  count = count > 0 and count or 1

  local start_line = require("scratcher.utils").is_buf_empty(buf) and 0 or -1
  api.nvim_buf_set_lines(buf, start_line, -1, true, text)
  if count == 1 then return end

  for _ = 2, count do
    api.nvim_buf_set_lines(buf, -1, -1, true, text)
  end
end

return M
