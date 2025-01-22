local stub = require("luassert.stub")
local rearrange = require("rearrange")
local helper = require("tests.rearrange.helper")

describe("supports rearranging a single line", function()
  before_each(function()
    stub(vim.fn, "getcharstr")
  end)

  after_each(function()
    ---@diagnostic disable-next-line: undefined-field
    vim.fn.getcharstr:revert()
  end)

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
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("j")
          rearrange.rearrange()
          helper.wait(100)
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
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("k")
          rearrange.rearrange()
          helper.wait(100)
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
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("j")
          rearrange.rearrange()
          helper.wait(100)
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
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("k")
          rearrange.rearrange()
          helper.wait(100)
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
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("j")
          rearrange.rearrange()
          helper.wait(100)
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
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("k")
          rearrange.rearrange()
          helper.wait(100)
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
  before_each(function()
    stub(vim.fn, "getcharstr")
  end)

  after_each(function()
    ---@diagnostic disable-next-line: undefined-field
    vim.fn.getcharstr:revert()
  end)

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
          vim.cmd("normal! vj")
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("j")
          rearrange.rearrange()
          helper.wait(100)
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
          vim.cmd("normal! vj")
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("k")
          rearrange.rearrange()
          helper.wait(100)
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
          vim.cmd("normal! vj")
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("j")
          rearrange.rearrange()
          helper.wait(100)
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
          vim.cmd("normal! vj")
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("k")
          rearrange.rearrange()
          helper.wait(100)
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
          vim.cmd("normal! vj")
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("j")
          rearrange.rearrange()
          helper.wait(100)
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
          vim.cmd("normal! vj")
          ---@diagnostic disable-next-line
          vim.fn.getcharstr.returns("k")
          rearrange.rearrange()
          helper.wait(100)
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
  before_each(function()
    stub(vim.fn, "getcharstr")
  end)

  after_each(function()
    ---@diagnostic disable-next-line: undefined-field
    vim.fn.getcharstr:revert()
  end)

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

        ---@diagnostic disable-next-line
        vim.fn.getcharstr.returns("j")

        rearrange.rearrange()
        helper.wait(150)
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

        ---@diagnostic disable-next-line
        vim.fn.getcharstr.returns("k")

        rearrange.rearrange()
        helper.wait(150)
      end,
      expected = [[
        local one = "1"
        local two = {"2.3", "2.1", "2.2"}
      ]],
    })
  end)
end)

describe("supports expanding the range", function()
  before_each(function()
    stub(vim.fn, "getcharstr")
  end)

  after_each(function()
    ---@diagnostic disable-next-line: undefined-field
    vim.fn.getcharstr:revert()
  end)

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

        local count = 0
        local keys = { "l", "k" }

        -- Expand with l
        ---@diagnostic disable-next-line
        vim.fn.getcharstr.invokes(function()
          count = count + 1
          return keys[count]
        end)

        rearrange.rearrange()
        helper.wait(150)
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

        local count = 0
        local keys = { "l", "h", "j" }

        -- Expand with l
        ---@diagnostic disable-next-line
        vim.fn.getcharstr.invokes(function()
          count = count + 1
          return keys[count]
        end)

        rearrange.rearrange()
        helper.wait(200)
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

        local count = 0
        local keys = { "l", "j" }

        -- Expand with l
        ---@diagnostic disable-next-line
        vim.fn.getcharstr.invokes(function()
          count = count + 1
          return keys[count]
        end)

        rearrange.rearrange()
        helper.wait(150)
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

        local count = 0
        local keys = { "l", "l", "k" }

        -- Expand with l
        ---@diagnostic disable-next-line
        vim.fn.getcharstr.invokes(function()
          count = count + 1
          return keys[count]
        end)

        rearrange.rearrange()
        helper.wait(200)
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
