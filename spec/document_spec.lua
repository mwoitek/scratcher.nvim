local assert = require("luassert")

local fn = vim.fn

describe("Document", function()
  local Document = require("scratcher.document")

  describe(":is_loaded()", function()
    it("returns false for an unloaded buffer", function()
      local name = "test_doc"
      local path = fn.tempname()
      local doc = Document:new(name, path)
      local loaded = doc:is_loaded()
      assert.is_false(loaded)
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
  end)
end)
