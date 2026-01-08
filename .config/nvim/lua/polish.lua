vim.keymap.set("n", "<leader>gy", function()
  local file = vim.api.nvim_buf_get_name(0)
  local diff = vim.fn.system("git diff -U5 HEAD -- " .. vim.fn.shellescape(file))

  if vim.v.shell_error ~= 0 or diff == "" then
    print "No changes found"
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
  print "Git diff copied to clipboard!"
end, { desc = "Copy git diff to clipboard (markdown)" })
