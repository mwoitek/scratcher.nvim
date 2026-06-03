local Manager = {}
Manager.__index = Manager

local fs = vim.fs
local uv = vim.uv

function Manager:new(storage_dir)
  storage_dir = fs.abspath(fs.normalize(storage_dir))
  local o = { storage_dir = storage_dir, documents = {} }
  return setmetatable(o, self)
end

function Manager:setup_storage()
  local stat = uv.fs_stat(self.storage_dir)
  if type(stat) == "table" and stat.type == "directory" then return end
  local mode = tonumber("755", 8)
  local created = uv.fs_mkdir(self.storage_dir, mode)
  if type(created) ~= "boolean" or not created then
    local err = string.format("Failed to create directory: %s", self.storage_dir)
    error(err)
  end
end

return Manager
