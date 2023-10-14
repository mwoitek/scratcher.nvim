local M = {}

function M.is_dictionary(x)
  return type(x) == "table" and (vim.tbl_isempty(x) or not vim.tbl_islist(x))
end

function M.is_valid_position(position)
  return vim.tbl_contains({ "bottom", "top", "left", "right" }, position)
end

function M.is_integer(x)
  if type(x) ~= "number" then return false end
  local i, _ = math.modf(x)
  return i == x
end

function M.is_valid_width(width)
  if type(width) ~= "number" then return false end
  return width > 0 and width < (M.is_integer(width) and vim.o.columns or 1)
end

function M.is_valid_height(height)
  if type(height) ~= "number" then return false end
  return height > 0 and height < (M.is_integer(height) and vim.o.lines or 1)
end

return M
