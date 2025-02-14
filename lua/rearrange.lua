local _utils = require("custom.utils")
local utils = require("custom.utils")
local Line = require("rearrange.arrangable.line")
local finder = require("rearrange.finder")

---@alias Rearrange.Arrangable Rearrange.Arrangable.Line | Rearrange.Arrangable.Treesitter

---@class Rearrange.Module
---@field current_arrangable_highlight_ns integer
---@field finder Rearrange.ArrangableFinder?
---@field ts_node TSNode?
local M = {
  finder = nil,
  ts_node = nil,
}

---Get the current range that can be arranged
---@return Rearrange.ArrangableFinder? range
function M._get_arrangable_finder()
  local mode = vim.api.nvim_get_mode().mode

  if mode == "n" then
    return finder.find_arrangable()
  elseif mode == "v" or mode == "V" then
    -- Get the position of the start of the visual selection
    local v_start = vim.fn.getpos("v")
    -- Get the position of the current cursor, also the end of the visual selection
    local v_end = vim.fn.getpos(".")

    -- Exit visual mode
    local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "x", false)

    if v_start[2] <= v_end[2] then
      return finder.new(Line.new(v_start[2] - 1, v_end[2]))
    else
      return finder.new(Line.new(v_end[2] - 1, v_start[2]))
    end
  end
end

---@param arrangable Rearrange.Arrangable
function M._highlight_range(arrangable)
  local range = arrangable:range()
  vim.api.nvim_buf_set_extmark(0, M.current_arrangable_highlight_ns, range[1], range[2], {
    hl_group = arrangable:range_hl(),
    end_row = range[3],
    end_col = range[4],
    virt_text = { { string.rep(" ", 4) .. "Swap next: j | Swap prev: k | Expand: l | Shrink: h", "Comment" } },
  })
end

---@param arrangable Rearrange.Arrangable
function M._highlight_moveable_range(arrangable)
  local range = arrangable:moveable_range()
  if not range then
    return
  end

  -- Before the moveable range
  vim.api.nvim_buf_set_extmark(0, M.backdrop_highlight_ns, 0, 0, {
    hl_group = "Rearrange.Backdrop",
    end_row = range[1],
    end_col = range[2],
  })

  -- After the moveable range
  vim.api.nvim_buf_set_extmark(0, M.backdrop_highlight_ns, range[3], range[4], {
    hl_group = "Rearrange.Backdrop",
    end_row = vim.fn.line("$"),
    end_col = 0,
  })
end

function M._clear_current_arrangable_highlight()
  vim.api.nvim_buf_clear_namespace(0, M.current_arrangable_highlight_ns, 0, -1)
end

function M._clear_moveable_range_highlight()
  vim.api.nvim_buf_clear_namespace(0, M.backdrop_highlight_ns, 0, -1)
end

function M._listen_to_keypress()
  local cancel = function()
    M._clear_current_arrangable_highlight()
    M._clear_moveable_range_highlight()
  end

  local ok, ret = pcall(vim.fn.getcharstr)
  if not ok then
    return
  end

  local key = vim.fn.keytrans(ret)

  if key == "j" or key == "k" then
    local new_arrangable
    if key == "j" then
      new_arrangable = M.finder:current():swap_next()
    elseif key == "k" then
      new_arrangable = M.finder:current():swap_prev()
    end

    if new_arrangable then
      M._clear_current_arrangable_highlight()
      M.finder:update_current(new_arrangable)
      M._highlight_range(new_arrangable)

      -- Place the cursor at the swapped node
      vim.schedule(function()
        local new_range = new_arrangable:range()
        vim.api.nvim_win_set_cursor(0, { new_range[1] + 1, new_range[2] })
      end)
    end
  elseif key == "l" or key == "h" then
    local new_arrangable
    if key == "l" then
      new_arrangable = M.finder:expand()
    elseif key == "h" then
      new_arrangable = M.finder:shrink()
    end

    if new_arrangable then
      M._clear_current_arrangable_highlight()
      M._clear_moveable_range_highlight()
      M._highlight_range(M.finder:current())
      M._highlight_moveable_range(M.finder:current())
    end
  else
    -- Stop listening for key presses
    return cancel()
  end

  M._listen_to_keypress_defer()
end

function M._listen_to_keypress_defer()
  -- Try to redraw first, otherwise, getcharstr will block the UI
  vim.cmd("redraw")

  -- Defer to make sure Neovim has a change to redraw the screen
  -- Continue to listen for key presses
  vim.defer_fn(function()
    M._listen_to_keypress()
  end, 50)
end

function M.rearrange()
  local _finder = M._get_arrangable_finder()

  if _finder then
    M.finder = _finder
    M._highlight_range(_finder:current())
    M._highlight_moveable_range(_finder:current())
    M._listen_to_keypress_defer()
  end
end

function M.setup()
  M.current_arrangable_highlight_ns = vim.api.nvim_create_namespace("rearrange.current_arrangable")
  M.moveable_range_highlight_ns = vim.api.nvim_create_namespace("rearrange.moveable_range")
  M.backdrop_highlight_ns = vim.api.nvim_create_namespace("rearrange.backdrop")
  M.arrange_events_ns = vim.api.nvim_create_namespace("rearrange.arrange_events")

  local hl_info = vim.api.nvim_get_hl(0, { name = "CursorLineNr" })
  vim.api.nvim_set_hl(0, "Rearrange.CurrentLine", { undercurl = true, sp = hl_info.fg })

  vim.api.nvim_set_hl(0, "Rearrange.CurrentTreesitterNode", { link = "Visual" })
  vim.api.nvim_set_hl(0, "Rearrange.Backdrop", { link = "Comment" })

  vim.keymap.set({ "n", "v" }, "gm", M.rearrange)
end

return M
