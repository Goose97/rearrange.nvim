# rearrange.nvim

Rearrange code per lines or Treesitter nodes

## Table of contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Setup](#setup)
- [Usage](#usage)

## Features

## Requirements

- [Neovim 0.10+](https://github.com/neovim/neovim/releases)
- [Recommended] [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter): for Treesitter-powered rules, users need to install language parsers. `nvim-treesitter` provides an easy interface to manage them.

## Installation

rearrange.nvim supports multiple plugin managers

<details>
<summary><strong>lazy.nvim</strong></summary>

```lua
{
    "Goose97/rearrange.nvim",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
        require("rearrange").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
}
```
</details>

<details>
<summary><strong>packer.nvim</strong></summary>

```lua
use({
    "Goose97/rearrange.nvim",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
        require("rearrange").setup({
            -- Configuration here, or leave empty to use defaults
        })
    end
})
```
</details>

<details>
<summary><strong>mini.deps</strong></summary>

```lua
local MiniDeps = require("mini.deps");

MiniDeps.add({
    source = "Goose97/rearrange.nvim",
})

require("rearrange").setup({
    -- Configuration here, or leave empty to use defaults
})
```
</details>

## Setup

You will need to call `require("rearrange").setup()` to intialize the plugin.

```lua
```

<details>
<summary><strong>Default configuration</strong></summary>

```lua
{
}
```

</details>

### Keymaps

## Usage
