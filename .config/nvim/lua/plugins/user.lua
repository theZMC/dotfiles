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
        json = { "deno_fmt" },
        javascript = { "deno_fmt" },
        typescript = { "deno_fmt" },
        jsx = { "deno_fmt" },
        tsx = { "deno_fmt" },
        css = { "deno_fmt" },
        html = { "deno_fmt" },
        scss = { "deno_fmt" },
        sass = { "deno_fmt" },
        less = { "deno_fmt" },
        astro = { "deno_fmt", lsp_format = "never", stop_after_first = true },
        svelte = { "deno_fmt" },
        vue = { "deno_fmt" },
        sql = { "deno_fmt" },
        yaml = { "yamlfmt" },
        terraform = { "hcl" },
        hcl = { "hcl" },
        lua = { "stylua" },
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
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "deno", "yamlfmt", "hclfmt" })
    end,
  },
}
