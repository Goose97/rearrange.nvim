local utils = require("custom.utils")
local Line = require("rearrange.arrangable.line")
local Treesitter = require("rearrange.arrangable.treesitter")

---@alias Rearrange.ArrangableFinder.NextCallback fun(): Rearrange.Arrangable?, Rearrange.ArrangableFinder.NextCallback?

---@class Rearrange.ArrangableFinder
---@field list Rearrange.Arrangable[]
---@field index number
---@field _next Rearrange.ArrangableFinder.NextCallback?
local ArrangableFinder = {}

---@return Rearrange.Arrangable?
function ArrangableFinder:expand()
  -- If the entry exists in the list, return the next entry
  if self.index < #self.list then
    self.index = self.index + 1
    return self:current()
  end

  -- If not, try to product the next one
  if self._next then
    local next_arrangable, new_next = self._next()
    self._next = new_next

    if next_arrangable then
      table.insert(self.list, next_arrangable)
      self.index = self.index + 1
      return self:current()
    end
  end
end

---@return Rearrange.Arrangable?
function ArrangableFinder:shrink()
  if self.index > 1 then
    self.index = self.index - 1
    return self:current()
  end
end

---@return Rearrange.Arrangable
function ArrangableFinder:current()
  return self.list[self.index]
end

---@param arrangable Rearrange.Arrangable
function ArrangableFinder:update_current(arrangable)
  self.list[self.index] = arrangable
end

local M = {}

---@param node TSNode
---@param spec table
---@return boolean
local function check_with_spec(node, spec)
  for _, spec_item in pairs(spec) do
    if type(spec_item) == "string" then
      local match = spec_item == node:type()
      if match then
        return true
      end
    elseif type(spec_item) == "function" then
      local match = spec_item(node)
      if match then
        return true
      end
    end
  end

  return false
end

---@param filetype string
---@return string?
local function get_lang(filetype)
  -- Source: https://github.com/folke/noice.nvim/blob/5070aaeab3d6bf3a422652e517830162afd404e0/lua/noice/text/treesitter.lua
  local has_lang = function(lang)
    local ok, ret = pcall(vim.treesitter.language.add, lang)

    if vim.fn.has("nvim-0.11") == 1 then
      return ok and ret
    end

    return ok
  end

  -- Treesitter doesn't support jsx directly but through tsx
  local lang = filetype == "javascriptreact" and "tsx"
    or (vim.treesitter.language.get_lang(vim.bo.filetype) or vim.bo.filetype)
  return has_lang(lang) and lang or nil
end

---Expand the range to find the next arrangable
---@param start_node TSNode
---@param skip_line boolean Whether to skip line range
---@return Rearrange.Arrangable?, Rearrange.ArrangableFinder.NextCallback?
function M._find_arrangable(start_node, skip_line)
  local current_line = vim.fn.line(".") - 1
  local line_arrangable = Line.new(current_line, current_line + 1)

  ---@type TSNode?
  local current_node = start_node

  while current_node do
    -- If node spans more than one line, use the Line arrangable
    local srow, _, erow, _ = current_node:range()
    if erow - srow > 0 and not skip_line then
      -- We pass the line range, skip_line starts from the next range
      return line_arrangable, function()
        return M._find_arrangable(current_node, true)
      end
    end

    -- Check if the current node matches the spec
    local lang = get_lang(vim.bo.filetype)
    local spec = lang and require("rearrange.finder.specs")[lang] or {}
    if check_with_spec(current_node, spec) then
      local parent = current_node:parent()
      return Treesitter.new(current_node),
        parent and function()
          return M._find_arrangable(parent, skip_line)
        end
    end

    current_node = current_node:parent()
  end

  if skip_line then
    return nil, nil
  else
    return line_arrangable, nil
  end
end

---@return Rearrange.ArrangableFinder
function M.find_arrangable()
  local current_line = vim.fn.line(".") - 1
  local line_arrangable = Line.new(current_line, current_line + 1)

  local node = vim.treesitter.get_node({ bufnr = 0 })
  if not node then
    return M.new(line_arrangable)
  end

  ---During the first find, we can guarantee that the current arrangable exists
  local current, next = M._find_arrangable(node, false)
  ---@cast current -nil
  return M.new(current, next)
end

---@param arrangable Rearrange.Arrangable The current arrangable
---@param next? fun(): Rearrange.Arrangable? Callback to get the next arrangable
---@return Rearrange.ArrangableFinder
function M.new(arrangable, next)
  local o = { list = { arrangable }, index = 1, _next = next }

  setmetatable(o, ArrangableFinder)
  ArrangableFinder.__index = ArrangableFinder
  return o
end

return M
