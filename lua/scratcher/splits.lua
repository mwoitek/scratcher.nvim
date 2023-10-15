local function compute_dimension(opts, dim)
  if dim ~= "width" and dim ~= "height" then error("invalid dimension", 2) end

  local val = opts[dim]
  if require("scratcher.validation").is_integer(val) then return val end

  local max_val = dim == "width" and vim.o.columns or vim.o.lines
  return math.floor(val * max_val)
end

local M = {}

function M.split_cmd(opts)
  local cmd
  if opts.position == "bottom" or opts.position == "top" then
    cmd = string.format(
      "%s %d split +",
      opts.position == "bottom" and "belowright" or "aboveleft",
      compute_dimension(opts, "height")
    )
  else
    cmd = string.format(
      "%s %d vsplit +",
      opts.position == "right" and "belowright" or "aboveleft",
      compute_dimension(opts, "width")
    )
  end
  return cmd
end

return M
