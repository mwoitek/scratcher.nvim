local assert = require("luassert")

local api = vim.api
local fn = vim.fn

describe("Document", function()
  local Document = require("scratcher.document")

  teardown(function()
    local bufs = api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
      if api.nvim_buf_is_loaded(buf) then pcall(api.nvim_buf_delete, buf, { unload = true }) end
    end
  end)

  describe(":is_loaded()", function()
    it("returns false for an unloaded buffer", function()
      local name = "test_doc"
      local path = fn.tempname()
      local doc = Document:new(name, path)
      local loaded = doc:is_loaded()
      assert.is_false(loaded)
    end)
  end)

  describe(":create()", function()
    it("creates the file if path refers to a non-existing file", function()
      local name = "non_existing_doc"
      local path = fn.tempname()
      local doc = Document:new(name, path)
      assert.is_false(doc:exists())
      doc:create()
      assert.is_true(doc:exists())
    end)
  end)

  describe(":load()", function()
    it("loads an existing file", function()
      local name = "existing_doc"
      local path = os.tmpname()
      local doc = Document:new(name, path)
      doc:load()
      local loaded = doc:is_loaded()
      assert.is_true(loaded)
      local buf = doc:buffer()
      assert.is_true(type(buf) == "number")
    end)

    it("loads a file that has to be created first", function()
      local name = "non_existing_doc"
      local path = fn.tempname()
      local doc = Document:new(name, path)
      assert.is_false(doc:exists())
      doc:load()
      assert.is_true(doc:exists())
      assert.is_true(doc:is_loaded())
      local buf = doc:buffer()
      assert.is_true(type(buf) == "number")
    end)
  end)
end)
