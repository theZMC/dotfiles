local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

local function close_telescope_picker(bufnr)
  local ok_actions, actions = pcall(require, "telescope.actions")
  local ok_state, state = pcall(require, "telescope.state")

  if not ok_actions or not ok_state then return false end

  for _, prompt_bufnr in ipairs(state.get_existing_prompt_bufnrs()) do
    local status = state.get_status(prompt_bufnr)

    if status.prompt_bufnr == bufnr or status.results_bufnr == bufnr or status.preview_bufnr == bufnr then
      actions.close(prompt_bufnr)
      return true
    end
  end

  return false
end

local function map_q_to_close_popup(bufnr)
  vim.keymap.set("n", "q", function()
    if close_telescope_picker(bufnr) then return end

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

    local filetype = vim.bo[args.buf].filetype
    local buftype = vim.bo[args.buf].buftype

    if buftype == "" and not filetype:match "^Telescope" then return end

    map_q_to_close_popup(args.buf)
  end,
})
