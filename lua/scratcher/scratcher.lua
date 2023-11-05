local api = vim.api

local Options = require "scratcher.options"

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
  scratcher.opts = Options:new(raw_opts)
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

  if not self.opts.auto_hide.enable then return end

  if not self.timer then self.timer = vim.loop.new_timer() end

  api.nvim_create_autocmd("WinEnter", {
    group = group_id,
    callback = function()
      if self.win == api.nvim_get_current_win() then
        self.timer:stop()
      elseif not self.timer:is_active() then
        self.timer:start(
          math.floor(self.opts.auto_hide.timeout * 60000),
          0,
          vim.schedule_wrap(function() api.nvim_win_close(self.win, true) end)
        )
      end
    end,
  })
end

function Scratcher:create_buf_autocmds()
  if not self.buf then error "cannot create autocmds, uninitialized buffer" end

  api.nvim_create_autocmd("BufWipeout", {
    group = api.nvim_create_augroup("ScratcherBufAutocmds", {}),
    buffer = self.buf,
    callback = function()
      self.buf = nil
      api.nvim_del_augroup_by_name "ScratcherBufAutocmds"
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

function Scratcher:clear()
  if not self.buf then error "failed to clear buffer, uninitialized buffer" end
  if not api.nvim_buf_is_loaded(self.buf) then
    error "failed to clear buffer, cannot operate on buffer lines"
  end
  api.nvim_buf_set_lines(self.buf, 0, -1, true, {})
end

function Scratcher:start_in_insert()
  if not self.opts.start_in_insert then return end

  if require("scratcher.utils").is_buf_empty(self.buf) then
    self:clear()
  else
    api.nvim_buf_set_lines(self.buf, -1, -1, true, { "" })
    local pos = { api.nvim_buf_line_count(self.buf), 0 }
    api.nvim_win_set_cursor(self.win, pos)
  end

  vim.cmd.startinsert()
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

---@param count number
function Scratcher:paste(count)
  local curr_buf = api.nvim_get_current_buf()
  if curr_buf == self.buf then return end

  local paste = require "scratcher.paste"
  local mode = api.nvim_get_mode().mode

  local text = paste.get_text_from_selection(curr_buf, mode)
  self:open(true)
  paste.paste(self.buf, text, count)
end

return Scratcher
