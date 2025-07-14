local M = {}

local valid = require "scratcher.validation"

---@param path string
---@param interactive boolean?
---@return boolean
function M.create_directory(path, interactive)
  vim.validate("path", path, "string", "directory path as a string")
  vim.validate("interactive", interactive, "boolean", true, "boolean or nil")

  local abs_path = vim.fs.abspath(vim.fs.normalize(path))
  if interactive == nil then interactive = true end -- interactive by default

  if valid.is_valid_directory(abs_path) then
    if interactive then
      local msg = string.format("Directory %s already exists. Nothing to do.", abs_path)
      vim.notify(msg, vim.log.levels.INFO)
    end
    return true
  end

  if interactive then
    local prompt = string.format("Directory %s will be created. Proceed?", abs_path)
    local ans = vim.fn.confirm(prompt, "&Yes\n&No")
    if ans ~= 1 then return false end
  end

  local created = vim.fn.mkdir(abs_path, "p") == 1

  if interactive then
    if created then
      local msg = string.format("Directory %s created successfully.", abs_path)
      vim.notify(msg, vim.log.levels.INFO)
    else
      local msg = string.format("Directory %s could not be created!", abs_path)
      vim.notify(msg, vim.log.levels.ERROR)
    end
  end

  return created
end

return M
