return {
  lsp = {
    {
      name = "astro",
      cmd = "astro-ls",
    },
  },
  formatters_by_ft = {
    astro = { "deno_fmt" },
  },
  format_on_save = {
    astro = "never",
  },
}
