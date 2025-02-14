local js_like = {
  function(node)
    local parent = node:parent()
    if not parent then
      return false
    end

    local parent_type = parent:type()
    local node_type = node:type()
    -- Object key-value pairs
    return (parent_type == "object" and node_type == "pair")
      -- Array items
      or (parent_type == "array")
      -- Object destructuring
      or (parent_type == "object_pattern" and node_type == "pair_pattern")
      -- Function arguments
      or (parent_type == "formal_parameters")
      -- Function parameters
      or (parent_type == "arguments")
  end,
}

return {
  lua = {
    "field",
    "function_declaration",
    function(node)
      local parent = node:parent()
      return parent and (vim.list_contains({ "arguments", "parameters" }, parent:type()))
    end,
  },
  javascript = js_like,
  typescript = js_like,
  javascriptreact = js_like,
  elixir = {
    function(node)
      local parent = node:parent()
      return parent and (vim.list_contains({ "body", "do_block", "arguments" }, parent:type()))
    end,
    function(node)
      local parent = node:parent()
      return parent
        and (vim.list_contains({ "do_block", "anonymous_function" }, parent:type()))
        and (vim.list_contains({ "stab_clause" }, node:type()))
    end,
  },
}
