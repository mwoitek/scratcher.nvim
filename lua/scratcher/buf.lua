local M = {}

local fs = require "scratcher.fs"
local valid = require "scratcher.validation"

---@param pattern string
---@return integer[]?
function M.find_buffers(pattern)
  vim.validate("pattern", pattern, "string", "pattern for the buffer name")

  ---@type integer[]
  local matches = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf):match(pattern) then
      table.insert(matches, buf)
    end
  end

  if #matches > 0 then return matches end
end

---@param buf integer?
function M.create_save_autocmds(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  if buf == nil or buf == 0 then buf = vim.api.nvim_get_current_buf() end

  local group_name = string.format("ScratcherBufAutocmds.%d", buf)
  local group = vim.api.nvim_create_augroup(group_name, {})

  vim.api.nvim_create_autocmd("BufModifiedSet", {
    group = group,
    buffer = buf,
    callback = function() vim.bo[buf].modified = false end,
  })

  vim.api.nvim_create_autocmd({ "BufHidden", "BufUnload" }, {
    group = group,
    buffer = buf,
    callback = function(ev)
      vim.api.nvim_buf_call(buf, function() vim.cmd "silent write" end)
      if ev.event == "BufUnload" then vim.api.nvim_del_augroup_by_id(group) end
    end,
  })
end

---@param buf integer?
function M.configure_scratch_buffer(buf)
  -- NOTE: This function is meant to be used with persistent scratch
  -- buffers. Temporary buffers will be configured in the act of their creation.
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  buf = buf or 0
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].buflisted = false
  M.create_save_autocmds(buf)
end

---@param file_path string?
---@return integer
function M.create_scratch_buffer(file_path)
  vim.validate("file_path", file_path, "string", true, "string or nil")

  ---@type integer
  local buf

  if not file_path then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "[scratcher]")
    return buf
  end

  local bufs = M.find_buffers(file_path)
  if bufs then
    buf = bufs[1]
  else
    buf = fs.edit_file(file_path)
    M.configure_scratch_buffer(buf)
  end
  return buf
end

---@param buf integer?
-- FIXME
function M.change_to_insert(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  vim.api.nvim_buf_call(buf or 0, function()
    vim.cmd "normal! 0G"
    local line = vim.api.nvim_get_current_line()
    local key = vim.trim(line):len() > 0 and "o" or "C"
    local cmd = string.format("normal! %s", key)
    vim.cmd(cmd)
  end)
end

---@param buf integer?
function M.clear(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  vim.api.nvim_buf_set_lines(buf or 0, 0, -1, true, {})
end

return M
