local Manager = {}
Manager.__index = Manager

local Config = require("scratcher.config")
local Document = require("scratcher.document")

local fn = vim.fn
local fs = vim.fs
local uv = vim.uv

function Manager:new(storage_dir)
  storage_dir = storage_dir or Config.get("storage_dir")
  storage_dir = fs.abspath(fs.normalize(storage_dir))
  local o = { storage_dir = storage_dir, documents = {} }
  return setmetatable(o, self)
end

function Manager:storage_exists()
  local stat = uv.fs_stat(self.storage_dir)
  return type(stat) == "table" and stat.type == "directory"
end

function Manager:storage_create()
  if self:storage_exists() then return end
  if fn.mkdir(self.storage_dir, "p") == 0 then
    local err = string.format("Failed to create directory: %s", self.storage_dir)
    error(err)
  end
end

function Manager:storage()
  if not self:storage_exists() then self:storage_create() end
  return self.storage_dir
end

function Manager:file_name(name, ext)
  name = vim.trim(name)
  if name:len() == 0 then error("Name must be non-empty") end
  ext = vim.trim(ext or Config.get("extension"))
  return ext:len() == 0 and name or string.format("%s.%s", name, ext)
end

function Manager:document(name, ext)
  local file_name = self:file_name(name, ext)
  local doc = self.documents[file_name]
  if doc ~= nil then return doc end
  name = fn.fnamemodify(file_name, ":r")
  local path = fs.joinpath(self:storage(), file_name)
  self.documents[file_name] = Document:new(name, path)
  return self.documents[file_name]
end

function Manager:open(name, ext)
  self:document(name, ext):load()
end

function Manager:close(name, ext)
  self:document(name, ext):unload()
end

function Manager:save(name, ext)
  self:document(name, ext):save()
end

return Manager:new()
