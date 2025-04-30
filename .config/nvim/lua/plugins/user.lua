---@type LazySpec
return {
  { "Saghen/blink.cmp", version = "*", build = "cargo build --release" },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    optional = true,
    opts = {
      preset = "minimal",
      options = {
        multilines = true,
        show_source = true,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    optional = true,
    opts = {
      model = "claude-3.7-sonnet",
      window = {
        layout = "float",
      },
    },
  },
}
