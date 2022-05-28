local M = {}

local create_command = function(cmd_name, position)
  vim.api.nvim_create_user_command(cmd_name, function()
    require("scratcher").new_scratch({
      position = position,
    })
  end, { bang = true })
end

M.setup_commands = function()
  vim.api.nvim_create_user_command("ScratcherNew", function()
    require("scratcher").new_scratch()
  end, { bang = true })

  create_command("ScratcherNewAbove", "top")
  create_command("ScratcherNewBelow", "bottom")
  create_command("ScratcherNewLeft", "left")
  create_command("ScratcherNewRight", "right")
end

return M
