local Document = {}
Document.__index = Document

local api = vim.api
local fn = vim.fn

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

function Document:load_buffer()
  if self:is_loaded() then return self.buf end
  self.buf = fn.bufadd(self.path)
  fn.bufload(self.buf)
  vim.bo[self.buf].bufhidden = "hide"
  vim.bo[self.buf].buflisted = false
  return self.buf
end

function Document:unload_buffer()
  api.nvim_buf_delete(self:buffer(), { unload = true })
  self.buf = nil
end

-- TODO: add "create" method

function Document:exists()
  local stat = vim.uv.fs_stat(self.path)
  return type(stat) == "table" and stat.type == "file"
end

function Document:save()
  api.nvim_buf_call(self:buffer(), vim.cmd.update)
end

return Document
