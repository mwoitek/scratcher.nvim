local M = {}

local valid = require "scratcher.validation"

---@param path string
---@param interactive boolean?
---@return boolean
function M.mkdir(path, interactive)
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

---@param dir_path string
---@return string[]
function M.get_files(dir_path)
  vim.validate("dir_path", dir_path, valid.is_valid_directory, "path to an existing directory")
  local abs_path = vim.fs.abspath(vim.fs.normalize(dir_path))

  local files = {}

  for name, type_ in vim.fs.dir(abs_path) do
    if type_ == "file" then
      local full_path = vim.fs.joinpath(abs_path, name)
      table.insert(files, full_path)
    end
  end

  return files
end

---@param path string
---@param must_exist boolean?
---@return integer
function M.edit_file(path, must_exist)
  vim.validate("must_exist", must_exist, "boolean", true, "boolean or nil")

  if must_exist then
    vim.validate("path", path, valid.is_valid_file, "path to an existing file")
  else
    vim.validate("path", path, "string", "file path as a string")
  end

  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_get_current_buf()

  local abs_path = vim.fs.abspath(vim.fs.normalize(path))
  local cmd = string.format("hide edit %s", abs_path)
  vim.cmd(cmd)

  local new_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_win_set_buf(curr_win, curr_buf)
  return new_buf
end

return M
