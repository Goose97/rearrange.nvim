local stub = require("luassert.stub")
local rearrange = require("rearrange")
local helper = require("tests.rearrange.helper")
local keyboard_mock = require("tests.rearrange.helper.keyboard_mock")

function mock_keyboard_input(keys)
  stub(vim.fn, "getcharstr")
  local count = 0

  ---@diagnostic disable-next-line
  vim.fn.getcharstr.invokes(function()
    count = count + 1
    return keys[count]
  end)

  return function()
    ---@diagnostic disable-next-line
    vim.fn.getcharstr:revert()
  end
end

describe("supports rearranging a single line", function()
  describe("given the line is in the middle of the file", function()
    it("moves down one line with j", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local one = "1"
          local tw|o = "2"
          local three = "3"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "j", "" }, function()
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local one = "1"
          local three = "3"
          local two = "2"
        ]],
      })
    end)

    it("moves up one line with k", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local one = "1"
          local tw|o = "2"
          local three = "3"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "k", "" }, function()
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local two = "2"
          local one = "1"
          local three = "3"
        ]],
      })
    end)
  end)

  describe("given the line is at the top of the file", function()
    it("moves down one line with j", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local on|e = "1"
          local two = "2"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "j", "" }, function()
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local two = "2"
          local one = "1"
        ]],
      })
    end)

    it("CAN NOT move up one line with k", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local on|e = "1"
          local two = "2"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "k", "" }, function()
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local one = "1"
          local two = "2"
        ]],
      })
    end)
  end)

  describe("given the line is at the bottom of the file", function()
    it("CAN NOT move down one line with j", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local one = "1"
          local tw|o = "2"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "j", "" }, function()
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local one = "1"
          local two = "2"
        ]],
      })
    end)

    it("moves up one line with k", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local one = "1"
          local tw|o = "2"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "k", "" }, function()
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local two = "2"
          local one = "1"
        ]],
      })
    end)
  end)
end)

describe("supports rearranging a block of lines", function()
  describe("given the block is in the middle of the file", function()
    it("moves down one line with j", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local one = "1"
          local tw|o = "2"
          local three = "3"
          local four = "4"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "j", "" }, function()
            vim.cmd("normal! vj")
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local one = "1"
          local four = "4"
          local two = "2"
          local three = "3"
        ]],
      })
    end)

    it("moves up one line with k", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local one = "1"
          local tw|o = "2"
          local three = "3"
          local four = "4"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "k", "" }, function()
            vim.cmd("normal! vj")
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local two = "2"
          local three = "3"
          local one = "1"
          local four = "4"
        ]],
      })
    end)
  end)

  describe("given the block is at the top of the file", function()
    it("moves down one line with j", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local on|e = "1"
          local two = "2"
          local three = "3"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "j", "" }, function()
            vim.cmd("normal! vj")
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local three = "3"
          local one = "1"
          local two = "2"
        ]],
      })
    end)

    it("CAN NOT move up one line with k", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local on|e = "1"
          local two = "2"
          local three = "3"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "k", "" }, function()
            vim.cmd("normal! vj")
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local one = "1"
          local two = "2"
          local three = "3"
        ]],
      })
    end)
  end)

  describe("given the block is at the bottom of the file", function()
    it("CAN NOT move down one line with j", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local one = "1"
          local tw|o = "2"
          local three = "3"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "j", "" }, function()
            vim.cmd("normal! vj")
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local one = "1"
          local two = "2"
          local three = "3"
        ]],
      })
    end)

    it("moves up one line with k", function()
      rearrange.setup()

      helper.assert_scenario({
        input = [[
          local one = "1"
          local tw|o = "2"
          local three = "3"
        ]],
        filetype = "lua",
        action = function()
          keyboard_mock.run({ "k", "" }, function()
            vim.cmd("normal! vj")
            rearrange.rearrange()
          end)
        end,
        expected = [[
          local two = "2"
          local three = "3"
          local one = "1"
        ]],
      })
    end)
  end)
end)

describe("supports rearranging a block of Treesitter nodes", function()
  it("swaps with the next node with j", function()
    rearrange.setup()

    helper.assert_scenario({
      input = [[
        local one = "1"
        local two = {"2.|1", "2.2", "2.3"}
      ]],
      filetype = "lua",
      action = function()
        vim.treesitter.get_parser():parse()
        keyboard_mock.run({ "j", "j", "" }, function()
          rearrange.rearrange()
        end)
      end,
      expected = [[
        local one = "1"
        local two = {"2.2", "2.3", "2.1"}
      ]],
    })
  end)

  it("swaps with the previous node with k", function()
    rearrange.setup()

    helper.assert_scenario({
      input = [[
        local one = "1"
        local two = {"2.1", "2.2", "2.|3"}
      ]],
      filetype = "lua",
      action = function()
        vim.treesitter.get_parser():parse()
        keyboard_mock.run({ "k", "k", "" }, function()
          rearrange.rearrange()
        end)
      end,
      expected = [[
        local one = "1"
        local two = {"2.3", "2.1", "2.2"}
      ]],
    })
  end)
end)

describe("supports expanding the range", function()
  it("expands the range with l", function()
    rearrange.setup()

    helper.assert_scenario({
      input = [[
        local one = "1"
        local two = {"2.|1", "2.2", "2.3"}
      ]],
      filetype = "lua",
      action = function()
        vim.treesitter.get_parser():parse()
        keyboard_mock.run({ "l", "k", "" }, function()
          rearrange.rearrange()
        end)
      end,
      expected = [[
        local two = {"2.1", "2.2", "2.3"}
        local one = "1"
      ]],
    })
  end)

  it("shinks the range with h", function()
    rearrange.setup()

    helper.assert_scenario({
      input = [[
        local one = "1"
        local two = {"2.|1", "2.2", "2.3"}
      ]],
      filetype = "lua",
      action = function()
        vim.treesitter.get_parser():parse()
        keyboard_mock.run({ "l", "h", "j", "" }, function()
          rearrange.rearrange()
        end)
      end,
      expected = [[
        local one = "1"
        local two = {"2.2", "2.1", "2.3"}
      ]],
    })
  end)

  it("expands the range to the current line", function()
    rearrange.setup()

    helper.assert_scenario({
      input = [[
        foo("bar", {
          "one",
          "tw|o",
          "three",
        })
      ]],
      filetype = "lua",
      action = function()
        vim.treesitter.get_parser():parse()
        keyboard_mock.run({ "l", "j", "" }, function()
          rearrange.rearrange()
        end)
      end,
      expected = [[
        foo("bar", {
          "one",
          "three",
          "two",
        })
      ]],
    })
  end)

  it("expands the range pass the current line", function()
    rearrange.setup()

    helper.assert_scenario({
      input = [[
        foo("bar", {
          "one",
          "tw|o",
          "three",
        })
      ]],
      filetype = "lua",
      action = function()
        vim.treesitter.get_parser():parse()
        keyboard_mock.run({ "l", "l", "k", "" }, function()
          rearrange.rearrange()
        end)
      end,
      expected = [[
        foo({
          "one",
          "two",
          "three",
        }, "bar")
      ]],
    })
  end)
end)
