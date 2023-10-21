local ScratchBuffer = {}

function ScratchBuffer:new()
  local obj = {}
  setmetatable(obj, { __index = self })
  return obj
end

function ScratchBuffer:_create_win_autocmds(opts)
  if not self.win then return end

  if not opts.auto_hide.enable then
    vim.api.nvim_create_autocmd("WinEnter", {
      group = vim.api.nvim_create_augroup("ScratcherAutocmds", { clear = false }),
      callback = function()
        if not vim.api.nvim_win_is_valid(self.win) then
          self.win = nil
          return true
        end
      end,
    })
    return
  end

  if opts.auto_hide.timeout == 0 then
    vim.api.nvim_create_autocmd("WinEnter", {
      group = vim.api.nvim_create_augroup("ScratcherAutocmds", { clear = false }),
      callback = function()
        if not vim.api.nvim_win_is_valid(self.win) then
          self.win = nil
          return true
        end
        if self.win ~= vim.api.nvim_get_current_win() then
          vim.api.nvim_win_close(self.win, true)
          self.win = nil
          return true
        end
      end,
    })
    return
  end

  -- TODO: Implement case timeout > 0
end

function ScratchBuffer:_create_buf_autocmds()
  if not self.buf then return end
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = vim.api.nvim_create_augroup("ScratcherAutocmds", { clear = false }),
    once = true,
    buffer = self.buf,
    callback = function()
      self.buf = nil
      return true
    end,
  })
end

local function compute_dimension(opts, dim)
  if dim ~= "width" and dim ~= "height" then error("invalid dimension", 2) end

  local val = opts[dim]
  if not val or type(val) ~= "number" then error("invalid dimension value", 2) end

  if require("scratcher.validation").is_integer(val) then return val end

  local max_val = dim == "width" and vim.o.columns or vim.o.lines
  return math.floor(val * max_val)
end

local function split_cmd(opts)
  local cmd
  if opts.position == "bottom" or opts.position == "top" then
    cmd = string.format(
      "%s %d split +",
      opts.position == "bottom" and "belowright" or "aboveleft",
      compute_dimension(opts, "height")
    )
  elseif opts.position == "right" or opts.position == "left" then
    cmd = string.format(
      "%s %d vsplit +",
      opts.position == "right" and "belowright" or "aboveleft",
      compute_dimension(opts, "width")
    )
  else
    error("failed to create split command, invalid position", 2)
  end
  return cmd
end

function ScratchBuffer:open(opts)
  if self.win then
    vim.api.nvim_set_current_win(self.win)
  else
    vim.cmd(split_cmd(opts))
    self.win = vim.api.nvim_get_current_win()
    self:_create_win_autocmds(opts)
  end

  if not self.buf then
    self.buf = vim.api.nvim_create_buf(false, true)
    self:_create_buf_autocmds()
  end
  vim.api.nvim_win_set_buf(self.win, self.buf)

  if opts.start_in_insert then vim.cmd [[execute 'normal! G' | startinsert!]] end
end

return {
  ScratchBuffer = ScratchBuffer,
}
