local Options = {
  position = "top",
  width = 0.35,
  height = 0.2,
  start_in_insert = false,
  auto_hide = {
    enable = false,
    timeout = 5, -- minutes
  },
}
local VALID_OPTIONS = vim.tbl_keys(Options)

function Options:new()
  local opts = {}
  setmetatable(opts, { __index = self })
  return opts
end

local OptionsBuilder = {}

function OptionsBuilder:new()
  local builder = {}
  setmetatable(builder, { __index = self })
  builder.opts = Options:new()
  return builder
end

function OptionsBuilder:build()
  return self.opts
end

function OptionsBuilder:set_position(position)
  local valid_pos = require("scratcher.validation").is_valid_position(position)
  if valid_pos then
    self.opts.position = position
  else
    error("Invalid position was passed", 0)
  end
  return self
end

function OptionsBuilder:set_width(width)
  local valid_width = require("scratcher.validation").is_valid_width(width)
  if valid_width then
    self.opts.width = width
  else
    error("Invalid width was passed", 0)
  end
  return self
end

function OptionsBuilder:set_height(height)
  local valid_height = require("scratcher.validation").is_valid_height(height)
  if valid_height then
    self.opts.height = height
  else
    error("Invalid height was passed", 0)
  end
  return self
end

function OptionsBuilder:set_start_in_insert(start_in_insert)
  if type(start_in_insert) == "boolean" then
    self.opts.start_in_insert = start_in_insert
  else
    error("Invalid start_in_insert was passed", 0)
  end
  return self
end

function OptionsBuilder:set_auto_hide(auto_hide)
  local valid_auto_hide = require("scratcher.validation").is_valid_auto_hide(auto_hide)
  if valid_auto_hide then
    setmetatable(auto_hide, { __index = Options.auto_hide })
    self.opts.auto_hide = auto_hide
  else
    error("Invalid auto_hide was passed", 0)
  end
  return self
end

return {
  VALID_OPTIONS = VALID_OPTIONS,
  OptionsBuilder = OptionsBuilder,
}
