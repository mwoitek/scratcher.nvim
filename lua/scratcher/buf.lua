local M = {}

local fs = require "scratcher.fs"
local valid = require "scratcher.validation"

---@param buf integer?
function M.create_save_autocmds(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  if buf == nil or buf == 0 then buf = vim.api.nvim_get_current_buf() end

  local group_name = string.format("ScratcherBufAutocmds.%d", buf)
  local group = vim.api.nvim_create_augroup(group_name, {})

  vim.api.nvim_create_autocmd("BufModifiedSet", {
    group = group,
    buffer = buf,
    callback = function(ev) vim.bo[ev.buf].modified = false end,
  })

  vim.api.nvim_create_autocmd({ "BufHidden", "BufUnload" }, {
    group = group,
    buffer = buf,
    callback = function(ev)
      vim.api.nvim_buf_call(ev.buf, function() vim.cmd "silent write" end)
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

---@param buf integer?
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

---@param file_path string?
---@return integer
function M.create_scratch_buffer(file_path)
  vim.validate("file_path", file_path, "string", true, "string or nil")

  local buf

  -- Create temporary buffer when file path is not specified
  if not file_path then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "[scratcher]")
  else
    buf = fs.edit_file(file_path)
    M.configure_scratch_buffer(buf)
  end

  return buf
end

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
