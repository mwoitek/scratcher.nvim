local M = {}

local valid = require "scratcher.validation"

---@param width number
---@return integer
function M.compute_width(width)
  vim.validate("width", width, valid.is_positive, "positive number")
  local factor = math.floor(width) == width and 1 or vim.o.columns
  return math.min(math.floor(width * factor), vim.o.columns - 1)
end

---@param height number
---@return integer
function M.compute_height(height)
  vim.validate("height", height, valid.is_positive, "positive number")
  local factor = math.floor(height) == height and 1 or vim.o.lines
  return math.min(math.floor(height * factor), vim.o.lines - 1)
end

---@param rows integer
---@param cols integer
---@return integer row
---@return integer col
function M.compute_float_coordinates(rows, cols)
  vim.validate("rows", rows, valid.is_positive_integer, "positive integer")
  vim.validate("cols", cols, valid.is_positive_integer, "positive integer")
  local row = math.floor((vim.o.lines - rows) / 2)
  local col = math.floor((vim.o.columns - cols) / 2)
  return row, col
end

---@param position scratcher.Position
---@param size scratcher.Size
---@return vim.api.keyset.win_config
function M.get_window_geometry(position, size)
  vim.validate("position", position, valid.is_valid_position, "valid window position")
  -- NOTE: size is validated by the functions that use its value

  local config = {}

  if position == "float" then
    config.relative = "editor"
    config.width = M.compute_width(size.width)
    config.height = M.compute_height(size.height)
    config.row, config.col = M.compute_float_coordinates(config.height, config.width)
  else
    config.split = position
    config.win = -1
    if position == "left" or position == "right" then
      config.width = M.compute_width(size.width)
    else
      config.height = M.compute_height(size.height)
    end
  end

  return config
end

---@param position scratcher.Position
---@param size scratcher.Size
---@param config vim.api.keyset.win_config?
---@param enter boolean?
---@return integer
function M.open_win(position, size, config, enter)
  -- NOTE: position and size will be validated by the function that uses their values
  vim.validate("config", config, "table", true, "window config table or nil")
  vim.validate("enter", enter, "boolean", true, "boolean or nil")

  local win_geometry = M.get_window_geometry(position, size)
  config = vim.tbl_deep_extend("force", config or {}, win_geometry)

  -- by default, change focus to new window
  if enter == nil then enter = true end

  -- new window will display current buffer
  local win = vim.api.nvim_open_win(0, enter, config)

  if position == "left" or position == "right" then
    vim.wo[win].winfixwidth = true
  elseif position == "above" or position == "below" then
    vim.wo[win].winfixheight = true
  end

  return win
end

return M
