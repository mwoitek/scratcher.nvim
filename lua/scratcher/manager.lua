local Manager = {}
Manager.__index = Manager

local fn = vim.fn
local fs = vim.fs
local uv = vim.uv

function Manager:new(config)
  local o = { config = config, documents = {} }
  return setmetatable(o, self)
end

function Manager:storage()
  if self.storage_dir == nil then self.storage_dir = self.config:get("storage_dir") end
  return self.storage_dir
end

function Manager:storage_exists()
  local stat = uv.fs_stat(self:storage())
  return type(stat) == "table" and stat.type == "directory"
end

function Manager:storage_create()
  if self:storage_exists() then return end
  if fn.mkdir(self:storage(), "p") == 0 then
    local err = string.format("Failed to create directory: %s", self:storage())
    error(err)
  end
end

function Manager:extension()
  if self._extension == nil then self._extension = self.config:get("extension") end
  return self._extension
end

function Manager:file_name(name, extension)
  name = vim.trim(name)
  if name:len() == 0 then error("Name must be non-empty") end
  extension = vim.trim(extension or self:extension())
  return extension:len() == 0 and name or string.format("%s.%s", name, extension)
end

function Manager:document(name, extension)
  local file_name = self:file_name(name, extension)
  local doc = self.documents[file_name]
  if doc ~= nil then return doc end

  self:storage_create()

  name = fn.fnamemodify(file_name, ":r")
  local path = fs.joinpath(self:storage(), file_name)
  self.documents[file_name] = require("scratcher.document"):new(name, path)
  return self.documents[file_name]
end

function Manager:open(name, extension)
  self:document(name, extension):load()
end

function Manager:close(name, extension)
  self:document(name, extension):unload()
end

function Manager:delete(name, extension, strict)
  local doc = self:document(name, extension)
  local file_name = fn.fnamemodify(doc.path, ":t")
  doc:delete(strict)
  self.documents[file_name] = nil
end

function Manager:save(name, extension)
  self:document(name, extension):save()
end

return Manager
