local utils = require("custom.utils")
local M = {}

---@class Rearrange.Arrangable.Line
---@field start number
---@field end number
local Line = {}

function Line:range()
  return { self.start, 0, self["end"], 0 }
end

---@return Rearrange.Arrangable.Line? new_arrangable
function Line:swap_next()
  local last_line = vim.fn.line("$")

  if self["end"] < last_line then
    local lines = vim.api.nvim_buf_get_lines(0, self.start, self["end"], true)
    local line_below = vim.api.nvim_buf_get_lines(0, self["end"], self["end"] + 1, true)
    table.insert(lines, 1, line_below[1])
    vim.api.nvim_buf_set_lines(0, self.start, self["end"] + 1, true, lines)
    return M.new(self.start + 1, self["end"] + 1)
  end
end

---@return Rearrange.Arrangable.Line? new_arrangable
function Line:swap_prev()
  if self.start > 0 then
    local lines = vim.api.nvim_buf_get_lines(0, self.start, self["end"], true)
    local line_above = vim.api.nvim_buf_get_lines(0, self.start - 1, self.start, true)
    table.insert(lines, line_above[1])
    vim.api.nvim_buf_set_lines(0, self.start - 1, self["end"], true, lines)
    return M.new(self.start - 1, self["end"] - 1)
  end
end

function Line:moveable_range()
  return nil
end

---@param start_line number 0-based index
---@param end_line number 0-based index
function M.new(start_line, end_line)
  local o = { start = start_line, ["end"] = end_line }

  setmetatable(o, Line)
  Line.__index = Line
  return o
end

return M
