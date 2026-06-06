local M = {}

function M.setup(opts)
  local Config = require("scratcher.config")
  Config:setup(opts)
end

function M.open(name, ext)
  local Manager = require("scratcher.manager")
  Manager:open(name, ext)
end

return M
