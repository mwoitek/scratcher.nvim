local Document = {}
Document.__index = Document

local api = vim.api
local fn = vim.fn
local uv = vim.uv

function Document:new(name, path)
  local o = { name = name, path = path, buf = nil }
  return setmetatable(o, self)
end

function Document:is_loaded()
  return type(self.buf) == "number" and api.nvim_buf_is_loaded(self.buf)
end

function Document:buffer()
  if not self:is_loaded() then error("Buffer is not loaded") end
  return self.buf
end

function Document:exists()
  local stat = uv.fs_stat(self.path)
  return type(stat) == "table" and stat.type == "file"
end

function Document:create()
  if self:exists() then return end

  local mode = tonumber("644", 8)
  local file = uv.fs_open(self.path, "w", mode)
  if type(file) ~= "number" then
    local err = string.format("Failed to open file: %s", self.path)
    error(err)
  end

  local bytes_written = uv.fs_write(file, "")
  if type(bytes_written) ~= "number" then
    local err = string.format("Failed to write to file: %s", self.path)
    error(err)
  end

  local closed = uv.fs_close(file)
  if type(closed) ~= "boolean" or not closed then
    local err = string.format("Failed to close file: %s", self.path)
    error(err)
  end
end

function Document:load()
  if self:is_loaded() then return end

  local ok, err = pcall(self.create, self)
  if not ok then error(err) end

  self.buf = fn.bufadd(self.path)
  fn.bufload(self.buf)

  vim.bo[self.buf].bufhidden = "hide"
  vim.bo[self.buf].buflisted = false
end

function Document:unload()
  api.nvim_buf_delete(self:buffer(), { unload = true })
  self.buf = nil
end

function Document:clear()
  api.nvim_buf_set_lines(self:buffer(), 0, -1, true, {})
end

function Document:save()
  api.nvim_buf_call(self:buffer(), vim.cmd.update)
end

return Document
