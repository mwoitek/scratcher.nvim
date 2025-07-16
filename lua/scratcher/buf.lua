local M = {}

local valid = require "scratcher.validation"

---@param buf integer?
function M.clear(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  vim.api.nvim_buf_set_lines(buf or 0, 0, -1, true, {})
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
---@return boolean
function M.is_empty(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  local lines = vim.api.nvim_buf_get_lines(buf or 0, 0, -1, true)
  return vim.iter(lines):all(function(l) return vim.trim(l):len() == 0 end)
end

---@param buf integer?
function M.change_to_insert(buf)
  vim.validate("buf", buf, valid.is_valid_buffer, true, "valid buffer ID")
  vim.api.nvim_buf_call(buf or 0, function()
    vim.cmd "normal! 0G"
    local line = vim.api.nvim_get_current_line()
    if vim.trim(line):len() > 0 then
      vim.cmd "normal! o"
    else
      vim.cmd "normal! C"
    end
  end)
end

return M
