local api = vim.api

---@class Scratcher
---@field opts Options
---@field win number?
---@field buf number?
local Scratcher = {}

---@param raw_opts any
---@return Scratcher
function Scratcher:new(raw_opts)
  local scratcher = {}
  setmetatable(scratcher, { __index = self })
  scratcher.opts = require("scratcher.options"):new(raw_opts)
  return scratcher
end

function Scratcher:create_win_autocmds()
  if not self.win then error "cannot create autocmds, uninitialized window" end

  local group_id = api.nvim_create_augroup("ScratcherWinAutocmds", {})

  api.nvim_create_autocmd("WinClosed", {
    group = group_id,
    pattern = tostring(self.win),
    callback = function()
      self.win = nil
      if self.timer then self.timer:stop() end
      api.nvim_del_augroup_by_name "ScratcherWinAutocmds"
    end,
  })
end

---@param stay boolean?
function Scratcher:create_win(stay)
  if self.win then
    if not stay then api.nvim_set_current_win(self.win) end
    return
  end

  if stay then
    local win = api.nvim_get_current_win()

    vim.cmd(self.opts:split_cmd())
    self.win = api.nvim_get_current_win()

    api.nvim_set_current_win(win)
  else
    vim.cmd(self.opts:split_cmd())
    self.win = api.nvim_get_current_win()
  end

  self:create_win_autocmds()

  vim.wo[self.win].winfixwidth = true
  vim.wo[self.win].winfixheight = true
end

function Scratcher:create_buf()
  if self.buf then return end

  self.buf = api.nvim_create_buf(false, true)
  self:create_buf_autocmds()
  api.nvim_buf_set_name(self.buf, "[scratcher]")
end

---@param stay boolean?
function Scratcher:open(stay)
  vim.validate { stay = { stay, "boolean", true } }

  self:create_win(stay)
  self:create_buf()
  api.nvim_win_set_buf(self.win, self.buf)

  if not stay then self:start_in_insert() end
end

function Scratcher:toggle()
  if self.win then
    api.nvim_win_close(self.win, true)
  else
    self:open()
  end
end

return Scratcher
