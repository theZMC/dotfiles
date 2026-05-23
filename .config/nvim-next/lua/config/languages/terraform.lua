return {
  lsp = {
    {
      name = "terraformls",
      cmd = "terraform-ls",
    },
  },
  formatters_by_ft = {
    hcl = { "hclfmt" },
    terraform = { "hclfmt" },
  },
  formatters = {
    hclfmt = {
      command = "hclfmt",
      args = { "$FILENAME" },
      stdin = false,
    },
  },
}
