---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 1024, lines = 100000 },
      autopairs = true,
      cmp = true,
      diagnostics = true,
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_lines = {
        current_line = true,
      },
      virtual_text = {
        current_line = false,
      },
    },
    mappings = {
      v = {
        ["<CR>"] = { "an", desc = "Increment Treesitter selection" },
        ["<BS>"] = { "in", desc = "Decrement Treesitter selection" },
      },
      n = {
        -- Yank the git diff of the current file to the clipboard in markdown format
        ["<leader>gy"] = {
          function()
            local file = vim.api.nvim_buf_get_name(0)
            local diff = vim.fn.system("git diff -U5 HEAD -- " .. vim.fn.shellescape(file))

            if vim.v.shell_error ~= 0 or diff == "" then
              vim.notify("No git diff available for the current file", vim.log.levels.WARN)
              return
            end

            local lines = {}
            for line in diff:gmatch "[^\n]+" do
              if
                not line:match "^diff "
                and not line:match "^index "
                and not line:match "^%-%-%-"
                and not line:match "^%+%+%+"
              then
                table.insert(lines, line)
              end
            end

            local clean_diff = table.concat(lines, "\n")
            local markdown_diff = "```diff\n" .. clean_diff .. "\n```"

            vim.fn.setreg("+", markdown_diff)
            vim.notifyn("Git diff copied to clipboard", vim.log.levels.INFO)
          end,
          desc = "Copy git diff to clipboard (markdown)",
        },
      },
    },
  },
}
