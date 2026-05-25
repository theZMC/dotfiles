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
}
