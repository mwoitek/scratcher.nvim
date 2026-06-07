local assert = require("luassert")

local api = vim.api
local fn = vim.fn

describe("Document", function()
  local Document = require("scratcher.document")

  teardown(function()
    local bufs = api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
      if api.nvim_buf_is_loaded(buf) then
        api.nvim_buf_call(buf, function()
          vim.cmd("silent! bdelete!")
        end)
      end
    end
  end)

  describe(":is_loaded()", function()
    it("returns false for an unloaded buffer", function()
      local name = "test_doc"
      local path = fn.tempname()
      local doc = Document:new(name, path)
      assert.is_false(doc:is_loaded())
    end)
  end)

  describe(":buffer()", function()
    it("throws an error for an unloaded buffer", function()
      local name = "test_doc"
      local path = fn.tempname()
      local doc = Document:new(name, path)
      assert.is_false(doc:is_loaded())
      assert.has_error(function()
        return doc:buffer()
      end)
    end)
  end)

  describe(":exists()", function()
    it("returns true for an existing file", function()
      local name = "existing_doc"
      local path = os.tmpname()
      local doc = Document:new(name, path)
      assert.is_true(doc:exists())
    end)

    it("returns false for a non-existing file", function()
      local name = "non_existing_doc"
      local path = fn.tempname()
      local doc = Document:new(name, path)
      assert.is_false(doc:exists())
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
      assert.is_true(doc:is_loaded())
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

  describe(":unload()", function()
    it("fails to unload an unloaded buffer", function()
      local name = "test_doc"
      local path = fn.tempname()
      local doc = Document:new(name, path)
      assert.is_false(doc:is_loaded())
      assert.has_error(function()
        doc:unload()
      end)
    end)

    it("unloads a loaded buffer", function()
      local name = "existing_doc"
      local path = os.tmpname()
      local doc = Document:new(name, path)
      assert.is_false(doc:is_loaded())
      doc:load()
      assert.is_true(doc:is_loaded())
      doc:unload()
      assert.is_false(doc:is_loaded())
      assert.has_error(function()
        return doc:buffer()
      end)
    end)
  end)

  describe(":clear()", function()
    it("correctly clears a non-empty buffer", function()
      local name = "test_doc"
      local path = os.tmpname()
      local doc = Document:new(name, path)
      doc:load()
      local buf = doc:buffer()
      api.nvim_buf_set_lines(buf, 0, 0, true, { "First line", "Second line" })
      assert.is_true(vim.bo[buf].modified)
      doc:clear()
      local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.is_true(#lines == 1)
      assert.is_true(lines[1]:len() == 0)
    end)
  end)
end)
