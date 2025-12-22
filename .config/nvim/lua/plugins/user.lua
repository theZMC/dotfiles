---@type LazySpec
return {
  {
    "akinsho/toggleterm.nvim",
    optional = true,
    opts = {
      direction = "float",
    },
  },
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
    "zbirenbaum/copilot.lua",
    optional = true,
    opts = {
      filetypes = {
        markdown = true,
        yaml = true,
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      code = {
        border = "thick",
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
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        markdown = { "deno_fmt" },
        astro = { "deno_fmt", lsp_format = "never", stop_after_first = true },
        yaml = { "yamlfmt" },
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
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "yamlfmt", "hclfmt" })
    end,
  },
}
