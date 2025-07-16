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
