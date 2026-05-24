local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

local function map_q_to_close_popup(bufnr)
  vim.keymap.set("n", "q", function()
    local win = vim.api.nvim_get_current_win()

    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative ~= "" then
      vim.api.nvim_win_close(win, false)
    end
  end, { buffer = bufnr, desc = "Close popup", nowait = true, silent = true })
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight on yank",
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = group,
  desc = "Reload files changed outside Neovim",
  command = "checktime",
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  desc = "Keep terminal windows uncluttered",
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  group = group,
  desc = "Use q to close popup windows",
  callback = function(args)
    local win = vim.api.nvim_get_current_win()

    if vim.api.nvim_win_get_config(win).relative == "" then return end

    local buftype = vim.bo[args.buf].buftype

    if buftype == "" then return end

    map_q_to_close_popup(args.buf)
  end,
})
