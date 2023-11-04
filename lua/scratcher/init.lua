local M = {}

local configured = false

---@param opts any
function M.setup(opts)
  local Scratcher = require "scratcher.scratcher"
  M.scratcher = Scratcher:new(opts)
  M.scratcher:create_paste_cmd()

  configured = true
end

---@param clear boolean?
function M.scratch(clear)
  if not configured then
    vim.notify(
      "[scratcher] Failed to execute function. Plugin was not configured properly.",
      vim.log.levels.ERROR
    )
    return
  end

  M.scratcher:open()
  if clear then M.scratcher:clear() end
end

function M.scratch_toggle()
  if not configured then
    vim.notify(
      "[scratcher] Failed to execute function. Plugin was not configured properly.",
      vim.log.levels.ERROR
    )
    return
  end
  M.scratcher:toggle()
end

return M
