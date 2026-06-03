local Manager = {}
Manager.__index = Manager

local fs = vim.fs
local uv = vim.uv

function Manager:new(storage_dir)
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
  local mode = tonumber("755", 8)
  local created = uv.fs_mkdir(self.storage_dir, mode)
  if type(created) ~= "boolean" or not created then
    local err = string.format("Failed to create directory: %s", self.storage_dir)
    error(err)
  end
end

function Manager:storage()
  if not self:storage_exists() then self:storage_create() end
  return self.storage_dir
end

function Manager:path(name)
  return fs.joinpath(self:storage(), name)
end

return Manager
