local commands = require("scratcher.commands")
local options = require("scratcher.options")

local M = {}
local _opts

M.setup = function(opts)
  _opts = options.get_opts(opts)
  commands.setup_commands()
end

local split_cmd = function(opts)
  local cmd
  local h_split = opts.position == "bottom" or opts.position == "top"

  if h_split then
    local height = opts.height and opts.height or _opts.height
    cmd = opts.position == "bottom" and "belowright" or "aboveleft"
    cmd = string.format(cmd .. " %d split", height)
  else
    local width = opts.width and opts.width or _opts.width
    cmd = opts.position == "right" and "belowright" or "aboveleft"
    cmd = string.format(cmd .. " %d vsplit", width)
  end

  vim.cmd(cmd)
end

M.new_scratch = function(opts)
  opts = opts and opts or _opts
  split_cmd(opts)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)
end

return M
