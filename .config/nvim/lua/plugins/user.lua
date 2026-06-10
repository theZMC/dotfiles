---@type LazySpec
return {
  {
    "cpea2506/one_monokai.nvim",
    opts = {
      transparent = true,
      italics = true,
    },
  },
  {
    "folke/noice.nvim",
    optional = true,
    opts = {
      routes = {
        {
          filter = {
            event = "notify",
            find = "No information available",
          },
          opts = { skip = true },
        },
      },
      views = {
        confirm = {
          border = {
            style = "rounded",
          },
        },
        hover = {
          border = {
            style = "rounded",
          },
        },
        popup = {
          border = {
            style = "rounded",
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        markdown = { "deno_fmt" },
        astro = { "deno_fmt", lsp_format = "never", stop_after_first = true },
        yaml = { "yamlfmt" },
        toml = { "taplo" },
        terraform = { "hcl" },
        hcl = { "hcl" },
        zsh = {},
      },
      formatters = {
        yamlfmt = {
          prepend_args = { "-formatter", "indentless_arrays=true,retain_line_breaks=true,scan_folded_as_literal=true" },
        },
      },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    optional = true,
    opts = {
      direction = "float",
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    optional = true,
    -- disable buf and git tabs
    opts = {
      sources = {
        "filesystem",
      },
      source_selector = {
        winbar = false,
        statusline = false,
      },
    },
  },
}
