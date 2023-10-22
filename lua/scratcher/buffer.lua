local ScratchBuffer = {}

function ScratchBuffer:new()
  local obj = {}
  setmetatable(obj, { __index = self })
  return obj
end

function ScratchBuffer:_create_win_autocmds(opts)
  if not self._win then return end

  local callback
  if opts.auto_hide.enable then
    if not self._timer then self._timer = vim.loop.new_timer() end
    callback = function()
      if not vim.api.nvim_win_is_valid(self._win) then
        self._timer:stop()
        self._win = nil
        vim.api.nvim_del_autocmd(self._autocmd_id)
        self._autocmd_id = nil
      elseif self._win == vim.api.nvim_get_current_win() then
        self._timer:stop()
      else
        if self._timer:is_active() then return end
        self._timer:start(
          math.floor(opts.auto_hide.timeout * 60000),
          0,
          vim.schedule_wrap(function()
            self._timer:stop()
            vim.api.nvim_win_close(self._win, true)
            self._win = nil
            vim.api.nvim_del_autocmd(self._autocmd_id)
            self._autocmd_id = nil
          end)
        )
      end
    end
  else
    callback = function()
      if not vim.api.nvim_win_is_valid(self._win) then
        self._win = nil
        vim.api.nvim_del_autocmd(self._autocmd_id)
        self._autocmd_id = nil
      end
    end
  end

  self._autocmd_id = vim.api.nvim_create_autocmd("WinEnter", {
    group = vim.api.nvim_create_augroup("ScratcherAutocmds", { clear = false }),
    callback = callback,
  })
end

function ScratchBuffer:_create_buf_autocmds()
  if not self._buf then return end
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = vim.api.nvim_create_augroup("ScratcherAutocmds", { clear = false }),
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

return {
  ScratchBuffer = ScratchBuffer,
}
