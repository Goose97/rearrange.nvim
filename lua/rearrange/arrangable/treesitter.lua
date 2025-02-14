local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

---@class Rearrange.Arrangable.Treesitter
---@field node TSNode
local Treesitter = {}

---@return integer[] range
function Treesitter:range()
  local srow, scol, erow, ecol = self.node:range()
  return { srow, scol, erow, ecol }
end

---@return string hl_group
function Treesitter:range_hl()
  return "Rearrange.CurrentTreesitterNode"
end

local function closest_ancestor(node, ancestor_type)
  while node do
    if node:type() == ancestor_type then
      break
    end
    node = node:parent()
  end

  return node
end

---Took this function from https://github.com/nvim-treesitter/nvim-treesitter/blob/master/lua/nvim-treesitter/ts_utils.lua
---@return TSNode range Node A new range
local function swap_nodes(node_a, node_b)
  local range_a = ts_utils.node_to_lsp_range(node_a)
  local range_b = ts_utils.node_to_lsp_range(node_b)

  local text_a = vim.treesitter.get_node_text(node_a, 0)
  local text_b = vim.treesitter.get_node_text(node_b, 0)

  local edit1 = { range = range_a, newText = text_b }
  local edit2 = { range = range_b, newText = text_a }
  vim.lsp.util.apply_text_edits({ edit1, edit2 }, vim.api.nvim_get_current_buf(), "utf-8")

  local lines_a = vim.split(text_a, "\n", { trimempty = true })
  local lines_b = vim.split(text_b, "\n", { trimempty = true })
  local char_delta = 0
  local line_delta = 0
  if
    range_a["end"].line < range_b.start.line
    or (range_a["end"].line == range_b.start.line and range_a["end"].character <= range_b.start.character)
  then
    line_delta = #lines_b - #lines_a
  end

  if range_a["end"].line == range_b.start.line and range_a["end"].character <= range_b.start.character then
    if line_delta ~= 0 then
      char_delta = #lines_b[#lines_b] - range_a["end"].character

      -- add range_a.start.character if last line of range_a (now lines_b) does not start at 0
      if range_a.start.line == range_b.start.line + line_delta then
        char_delta = char_delta + range_a.start.character
      end
    else
      char_delta = #lines_b[#lines_b] - #lines_a[#lines_a]
    end
  end

  local new_start_line = range_b.start.line + line_delta
  local new_start_char = range_b.start.character + char_delta

  local new_range = {
    new_start_line,
    new_start_char,
    new_start_line + #lines_a - 1,
    -- This can change for multi-line nodes
    range_b["end"].character,
  }

  -- We need to force a parser update before getting the node. Maybe we can do better?
  vim.treesitter.get_parser():parse()

  local new_node = vim.treesitter.get_node({
    bufnr = 0,
    pos = { new_range[1], new_range[2] },
  })

  -- Query the node by range is not guarantee to work cause multiple
  -- nodes can have the same range. We perform the second lookup by node type
  new_node = closest_ancestor(new_node, node_a:type())

  if not new_node then
    error("Could not find new node after swap")
  end

  return new_node
end

---@return Rearrange.Arrangable.Treesitter? new_arrangable
function Treesitter:swap_next()
  local next_node = self.node:next_named_sibling()
  if not next_node then
    return nil
  end

  local new_node = swap_nodes(self.node, next_node)
  return M.new(new_node)
end

---@return Rearrange.Arrangable.Treesitter? new_arrangable
function Treesitter:swap_prev()
  local prev_node = self.node:prev_named_sibling()
  if not prev_node then
    return nil
  end

  local new_node = swap_nodes(self.node, prev_node)
  return M.new(new_node)
end

function Treesitter:moveable_range()
  local parent = self.node:parent()
  if not parent then
    return nil
  end

  local srow, scol, erow, ecol = parent:range()
  return { srow, scol, erow, ecol }
end

---@param node TSNode
function M.new(node)
  local o = { node = node }

  setmetatable(o, Treesitter)
  Treesitter.__index = Treesitter
  return o
end

return M
