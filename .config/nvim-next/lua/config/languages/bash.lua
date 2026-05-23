return {
  lsp = {
    {
      name = "bashls",
      cmd = "bash-language-server",
      config = {
        filetypes = { "bash", "sh" },
      },
    },
  },
  format_on_save = {
    zsh = false,
  },
}
