return {
  astro = {
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
  },
  bash = {
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
  },
  c = {
    lsp = {
      {
        name = "clangd",
        cmd = "clangd",
        config = {
          cmd = { "clangd", "--offset-encoding=utf-8" },
        },
      },
    },
  },
  css = {
    lsp = {
      {
        name = "cssls",
        cmd = "vscode-css-language-server",
      },
    },
  },
  docker = {
    lsp = {
      {
        name = "dockerls",
        cmd = "docker-langserver",
      },
    },
  },
  go = {
    lsp = {
      {
        name = "gopls",
        cmd = "gopls",
        config = {
          settings = {
            gopls = {
              analyses = {
                shadow = false,
              },
            },
          },
        },
      },
    },
  },
  helm = {
    lsp = {
      {
        name = "helm_ls",
        cmd = "helm_ls",
      },
    },
  },
  html = {
    lsp = {
      {
        name = "html",
        cmd = "vscode-html-language-server",
      },
    },
  },
  json = {
    lsp = {
      {
        name = "jsonls",
        cmd = "vscode-json-language-server",
      },
    },
  },
  lua = {
    lsp = {
      {
        name = "lua_ls",
        cmd = "lua-language-server",
        config = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
            },
          },
        },
      },
    },
    formatters_by_ft = {
      lua = { "stylua" },
    },
  },
  markdown = {
    lsp = {
      {
        name = "marksman",
        cmd = "marksman",
      },
    },
    formatters_by_ft = {
      markdown = { "deno_fmt" },
    },
  },
  python = {
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
  },
  rust = {
    lsp = {
      {
        name = "rust_analyzer",
        cmd = "rust-analyzer",
      },
    },
  },
  svelte = {
    lsp = {
      {
        name = "svelte",
        cmd = "svelteserver",
      },
    },
  },
  tailwind = {
    lsp = {
      {
        name = "tailwindcss",
        cmd = "tailwindcss-language-server",
      },
    },
  },
  terraform = {
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
  },
  toml = {
    lsp = {
      {
        name = "taplo",
        cmd = "taplo",
      },
    },
  },
  typescript = {
    lsp = {
      {
        name = "ts_ls",
        cmd = "typescript-language-server",
      },
    },
  },
  vue = {
    lsp = {
      {
        name = "vue_ls",
        cmd = "vue-language-server",
      },
    },
  },
  yaml = {
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
  },
}
