local M = {}

---@type Scratcher
local scratcher
local configured = false

---@param opts any
function M.setup(opts)
  M.raw_opts = opts
  scratcher = require("scratcher.scratcher"):new(opts)
  configured = true
end

---@param callback function
local function run_if_configured(callback)
  if not configured then
    vim.notify(
      "[scratcher] Failed to execute function. Plugin was not configured properly.",
      vim.log.levels.ERROR
    )
    return
  end
  callback()
end

---@param clear boolean?
function M.scratch(clear)
  run_if_configured(function()
    scratcher:open()
    if clear then scratcher:clear() end
  end)
end

function M.scratch_toggle()
  run_if_configured(function() scratcher:toggle() end)
end

function M.scratch_paste()
  run_if_configured(function() scratcher:paste(vim.v.count) end)
end

return M
