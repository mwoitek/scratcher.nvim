local M = {}

local ERROR = vim.log.levels.ERROR

---@type Scratcher
local scratcher
local configured = false

---@param opts any
function M.setup(opts)
  M.raw_opts = opts
  scratcher = require("scratcher.scratcher"):new(opts)
  configured = true
end

---@param clear boolean?
function M.scratch(clear)
  if not configured then
    vim.notify("[scratcher] Failed to execute function. Plugin was not configured properly.", ERROR)
    return
  end
  scratcher:open()
  if clear then scratcher:clear() end
end

function M.scratch_toggle()
  if not configured then
    vim.notify("[scratcher] Failed to execute function. Plugin was not configured properly.", ERROR)
    return
  end
  scratcher:toggle()
end

function M.scratch_paste()
  if not configured then
    vim.notify("[scratcher] Failed to execute function. Plugin was not configured properly.", ERROR)
    return
  end
  scratcher:paste()
end

return M
