return {
  lsp = {
    {
      name = "yamlls",
      cmd = "yaml-language-server",
    },
  },
  formatters_by_ft = {
    yaml = { "yamlfmt" },
  },
  formatters = {
    yamlfmt = {
      prepend_args = {
        "-formatter",
        "indentless_arrays=true,retain_line_breaks=true,scan_folded_as_literal=true",
      },
    },
  },
}
