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

  describe(":storage()", function()
    it("returns the default storage directory when none is specified", function()
      local config = Config:new()
      local man = Manager:new(config)
      local storage_dir = man:storage()
      assert.are.equal(type(storage_dir), "string")
      assert.is_true(storage_dir:len() > 0)
    end)
  end)

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

  describe(":storage_create()", function()
    it("correctly creates the storage directory", function()
      local storage_dir = fs.joinpath(get_tmp_dir(), "new_test_dir")
      local config = Config:new({ storage_dir = storage_dir })
      local man = Manager:new(config)
      assert.are.equal(man:storage(), storage_dir)
      assert.is_false(man:storage_exists())
      man:storage_create()
      assert.is_true(man:storage_exists())
    end)
  end)

  describe(":file_name()", function()
    it("fails when the name is an empty string", function()
      local config = Config:new({ extension = "md" })
      local man = Manager:new(config)
      local name = "     "
      assert.has_error(function()
        return man:file_name(name)
      end)
    end)

    it("generates the correct file name when no extension is specified", function()
      local extension = "org"
      local config = Config:new({ extension = extension })
      local man = Manager:new(config)
      local name = "  test_name "
      local file_name = man:file_name(name)
      assert.are.equal(fn.fnamemodify(file_name, ":t:r"), "test_name")
      assert.are.equal(fn.fnamemodify(file_name, ":e"), extension)
    end)
  end)
end)
