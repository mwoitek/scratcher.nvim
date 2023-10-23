local scratcher = {}

function scratcher.setup(opts)
  scratcher._buf = require("scratcher.buffer").ScratchBuffer:new()

  local options = require "scratcher.options"
  local builder = options.OptionsBuilder:new()

  local valid_arg = not opts or require("scratcher.validation").is_dictionary(opts)
  if not valid_arg then
    vim.notify("[scratcher] Bad argument to setup(). Using defaults.", vim.log.levels.WARN)
    scratcher._opts = builder:build()
    return
  end

  if not opts or vim.tbl_isempty(opts) then
    scratcher._opts = builder:build()
    return
  end

  local keys = vim.tbl_keys(opts)
  local valid_keys = vim.tbl_filter(function(key)
    return vim.tbl_contains(options.VALID_OPTIONS, key)
  end, keys)

  if vim.tbl_isempty(valid_keys) then
    vim.notify(
      "[scratcher] Options were passed to setup(), but all of them are unknown. Using defaults.",
      vim.log.levels.WARN
    )
    scratcher._opts = builder:build()
    return
  end
  if #keys > #valid_keys then
    vim.notify(
      "[scratcher] Some of the options passed to setup() are unknown. Ignoring.",
      vim.log.levels.WARN
    )
  end

  for _, opt in ipairs(valid_keys) do
    local ok, res = pcall(builder["set_" .. opt], builder, opts[opt])
    if ok then
      builder = res
    else
      vim.notify("[scratcher] " .. res .. ". Using default.", vim.log.levels.WARN)
    end
  end
  scratcher._opts = builder:build()
end

function scratcher.scratch(clear)
  if not scratcher._opts then return end
  scratcher._buf:open(scratcher._opts)
  if clear then scratcher._buf:clear() end
end

return scratcher
