return {
  "stevearc/conform.nvim",
  optional = true,
  opts = function(_, opts)
    -- Add deno_fmt to the list of formatters
    if not opts.formatters_by_ft then opts.formatters_by_ft = {} end

    -- For JavaScript and TypeScript files
    opts.formatters_by_ft.javascript = { "deno_fmt" }
    opts.formatters_by_ft.typescript = { "deno_fmt" }
    opts.formatters_by_ft.javascriptreact = { "deno_fmt" }
    opts.formatters_by_ft.typescriptreact = { "deno_fmt" }

    -- For JSON and Markdown if you want deno to format those too
    opts.formatters_by_ft.json = { "deno_fmt" }
    opts.formatters_by_ft.jsonc = { "deno_fmt" }
    opts.formatters_by_ft.markdown = { "deno_fmt" }
    opts.formatters_by_ft.yaml = { "deno_fmt" }

    -- Remove prettierd from the formatter list if it exists
    for _, formatters in pairs(opts.formatters_by_ft) do
      for i, formatter in ipairs(formatters) do
        if formatter == "prettierd" then
          table.remove(formatters, i)
          break
        end
      end
    end

    -- Configure the deno_fmt formatter if needed
    opts.formatters = opts.formatters or {}
    opts.formatters.deno_fmt = {
      -- You can add custom args if needed
      -- args = { ... }
    }

    return opts
  end,
}
