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

---@param stay boolean?
function Scratcher:open(stay)
  self:create_win(stay)
  self:create_buf()
  vim.api.nvim_win_set_buf(self.win, self.buf)
  if not stay then self:start_in_insert() end
end

function Scratcher:toggle()
  if self.win then
    vim.api.nvim_win_close(self.win, true)
  else
    self:open()
  end
end

return Scratcher
