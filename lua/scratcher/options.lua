local Options = {
  position = "bottom",
  width = 0.35,
  height = 0.2,
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

return {
  VALID_OPTIONS = VALID_OPTIONS,
  OptionsBuilder = OptionsBuilder,
}
