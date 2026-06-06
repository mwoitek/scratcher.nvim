if vim.g.scratcher_loaded ~= nil then return end
vim.g.scratcher_loaded = 1

vim.api.nvim_create_user_command("Scratch", function(t)
  local name = assert(t.fargs[1])
  local ext = t.fargs[2]
  require("scratcher").open(name, ext)
end, { nargs = 2 })
