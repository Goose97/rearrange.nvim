local KeyboardMock = {}

function KeyboardMock.new(keys)
  local o = { keys = keys, index = 0 }

  setmetatable(o, KeyboardMock)
  KeyboardMock.__index = KeyboardMock
  return o
end

function KeyboardMock:start()
  local stub = require("luassert.stub")
  stub(vim.fn, "getcharstr")

  ---@diagnostic disable-next-line
  vim.fn.getcharstr.invokes(function()
    self.index = self.index + 1

    if self.index == #self.keys and self.co then
      coroutine.resume(self.co)
    end

    return self.keys[self.index]
  end)
end

function KeyboardMock:stop()
  ---@diagnostic disable-next-line
  vim.fn.getcharstr:revert()
end

function KeyboardMock.run(keys, callback)
  local mock = KeyboardMock.new(keys)
  mock:start()
  callback()
  mock:wait_till_empty()
  mock:stop()
end

function KeyboardMock:wait_till_empty()
  if #self.keys == self.index then
    return
  end

  local co = coroutine.running()
  self.co = co
  coroutine.yield()
end

return KeyboardMock
