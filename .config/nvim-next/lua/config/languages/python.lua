return {
  lsp = {
    {
      name = "basedpyright",
      cmd = "basedpyright-langserver",
    },
    {
      name = "ruff",
      cmd = "ruff",
    },
  },
  formatters_by_ft = {
    python = { "ruff-fmt" },
  },
}
