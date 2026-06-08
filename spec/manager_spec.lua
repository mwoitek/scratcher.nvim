local assert = require("luassert")

local fn = vim.fn
local fs = vim.fs

local function get_tmp_dir()
  local tmp_file = fn.tempname()
  return fs.dirname(tmp_file) -- this directory actually exists
end

describe("Manager", function()
  local Config = require("scratcher.config")
  local Manager = require("scratcher.manager")

  describe(":storage_exists()", function()
    it("returns false when the storage directory does not exist", function()
      local storage_dir = fs.joinpath(get_tmp_dir(), "does_not_exist")
      local config = Config:new({ storage_dir = storage_dir })
      local man = Manager:new(config)
      assert.is_false(man:storage_exists())
    end)

    it("returns true when the storage directory exists", function()
      local storage_dir = get_tmp_dir()
      local config = Config:new({ storage_dir = storage_dir })
      local man = Manager:new(config)
      assert.is_true(man:storage_exists())
    end)
  end)
end)
