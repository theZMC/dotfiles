---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "one_monokai",
    status = {
      separators = {
        left = { "", "█" }, -- separator for the left side of the statusline
        right = { "█", "" }, -- separator for the right side of the statusline
        tab = { "█", "█" },
      },
    },
  },
}
