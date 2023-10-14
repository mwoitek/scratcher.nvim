local M = {}

local _opts

function M.setup(opts)
  local Options = require("scratcher.options").Options

  local valid_arg = not opts or require("scratcher.validation").is_dictionary(opts)
  if not valid_arg then
    vim.notify("[scratcher] Bad argument to setup(). Using defaults.", vim.log.levels.WARN)
    _opts = Options:new()
    return
  end

  if not opts or vim.tbl_isempty(opts) then
    _opts = Options:new()
    return
  end

  local keys = vim.tbl_keys(opts)
  local valid_keys = vim.tbl_filter(function(key)
    return vim.tbl_contains(Options.keys, key)
  end, keys)

  if vim.tbl_isempty(valid_keys) then
    vim.notify(
      "[scratcher] Options were passed to setup(), but all of them are unknown. Using defaults.",
      vim.log.levels.WARN
    )
    _opts = Options:new()
    return
  end
  if #keys > #valid_keys then
    vim.notify(
      "[scratcher] Some of the options passed to setup() are unknown. Ignoring.",
      vim.log.levels.WARN
    )
  end

  local builder = require("scratcher.options").OptionsBuilder:new()
  for _, opt in ipairs(valid_keys) do
    local ok, res = pcall(builder["set_" .. opt], builder, opts[opt])
    if ok then
      builder = res
    else
      vim.notify("[scratcher] " .. res .. ". Using default.", vim.log.levels.WARN)
    end
  end
  _opts = builder:build()
end

local function split_cmd(opts)
  local cmd
  local h_split = opts.position == "bottom" or opts.position == "top"

  if h_split then
    local height = opts.height and opts.height or _opts.height
    cmd = opts.position == "bottom" and "belowright" or "aboveleft"
    cmd = string.format("%s %d split", cmd, height)
  else
    local width = opts.width and opts.width or _opts.width
    cmd = opts.position == "right" and "belowright" or "aboveleft"
    cmd = string.format("%s %d vsplit", cmd, width)
  end

  vim.cmd(cmd)
end

function M._new_scratch(position)
  local opts
  if require("scratcher.validation").is_valid_position(position) then
    opts = { position = position }
    setmetatable(opts, { __index = _opts })
  else
    opts = _opts
  end

  -- TODO: Improve
  split_cmd(opts)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)
end

return M
