local ScratchBuffer = {}

function ScratchBuffer:new()
  local obj = {}
  setmetatable(obj, { __index = self })
  return obj
end

function ScratchBuffer:_create_win_autocmds(opts)
  if not self._win then return end

  vim.api.nvim_create_autocmd("WinClosed", {
    group = vim.api.nvim_create_augroup("ScratcherWinAutocmds", { clear = false }),
    pattern = tostring(self._win),
    callback = function()
      self._win = nil
      if self._timer then self._timer:stop() end
      vim.api.nvim_del_augroup_by_name "ScratcherWinAutocmds"
    end,
  })

  if not opts.auto_hide.enable then return end

  if not self._timer then self._timer = vim.loop.new_timer() end

  vim.api.nvim_create_autocmd("WinEnter", {
    group = vim.api.nvim_create_augroup("ScratcherWinAutocmds", { clear = false }),
    callback = function()
      if self._win == vim.api.nvim_get_current_win() then
        self._timer:stop()
      elseif self._timer:is_active() then
        return
      else
        self._timer:start(
          math.floor(opts.auto_hide.timeout * 60000),
          0,
          vim.schedule_wrap(function() vim.api.nvim_win_close(self._win, true) end)
        )
      end
    end,
  })
end

function ScratchBuffer:_create_buf_autocmds()
  if not self._buf then return end
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = vim.api.nvim_create_augroup("ScratcherBufAutocmds", { clear = false }),
    once = true,
    buffer = self._buf,
    callback = function()
      self._buf = nil
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
  if self._win then
    vim.api.nvim_set_current_win(self._win)
  else
    vim.cmd(split_cmd(opts))
    self._win = vim.api.nvim_get_current_win()
    self:_create_win_autocmds(opts)
  end

  if not self._buf then
    self._buf = vim.api.nvim_create_buf(false, true)
    self:_create_buf_autocmds()
  end
  vim.api.nvim_win_set_buf(self._win, self._buf)

  if opts.start_in_insert then vim.cmd [[execute 'normal! G' | startinsert!]] end
end

function ScratchBuffer:clear()
  if not self._buf or vim.api.nvim_buf_line_count(self._buf) == 0 then return end
  vim.api.nvim_buf_set_lines(self._buf, 0, -1, true, {})
end

return {
  ScratchBuffer = ScratchBuffer,
}
