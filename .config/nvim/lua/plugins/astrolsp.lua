local is_yaml = function(_, bufnr)
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  return filetype == "yaml" or filetype == "helm"
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    commands = {
      K8sSelectSchema = {
        function() require("k8s_schema").select() end,
        cond = is_yaml,
      },
    },
    mappings = {
      n = {
        ["<leader>lK"] = {
          function() vim.cmd "K8sSelectSchema" end,
          desc = "Select K8s yaml schema",
          cond = is_yaml,
        },
      },
    },
    ---@diagnostic disable: missing-fields
    config = {
      clangd = { capabilities = { offsetEncoding = "utf-8" } },
      jsonls = {
        filetypes = { "json", "jsonc", "json5" },
      },
      gopls = {
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
}
