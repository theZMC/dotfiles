local buffers = require "config.buffers"
local pick = require "config.pick"

local map = vim.keymap.set

local function diagnostic_jump(count, severity)
  return function()
    vim.diagnostic.jump {
      count = count,
      severity = severity,
    }
  end
end

local function focus_neotree()
  if vim.bo.filetype == "neo-tree" then
    local ok, neo_tree = pcall(require, "neo-tree")

    if ok then
      local prior = neo_tree.get_prior_window()

      if prior > 0 and vim.api.nvim_win_is_valid(prior) then
        vim.api.nvim_set_current_win(prior)
        return
      end
    end

    vim.cmd "wincmd p"
    return
  end

  require("neo-tree.command").execute {
    action = "focus",
    source = "filesystem",
    position = "left",
    reveal = true,
  }
end

map("n", "]b", function() buffers.cycle(1, vim.v.count1) end, { desc = "󰒭 Next Buffer" })

map("n", "[b", function() buffers.cycle(-1, vim.v.count1) end, { desc = "󰒮 Previous Buffer" })

map("n", "<leader>c", buffers.close_current, { desc = "󰅖 Close Current Buffer" })
map("n", "<leader>bd", buffers.pick_to_close, { desc = "󰆴 Close Buffer" })
map("n", "<leader>q", "<cmd>confirm qall<cr>", { desc = "󰗼 Quit Neovim" })
map("n", "<F7>", function() require("config.terminal").toggle() end, { desc = " Toggle Terminal" })
map("n", "<leader>tt", function() require("config.terminal").toggle() end, { desc = " Toggle Terminal" })
map("t", "<F7>", [[<C-\><C-n><cmd>lua require('config.terminal').toggle()<CR>]], { desc = " Toggle Terminal" })
map("n", "<leader>gg", function() require("config.terminal").lazygit() end, { desc = "󰊢 LazyGit" })
map("n", "<leader>ac", "<cmd>CopilotChatToggle<cr>", { desc = "󰚩 Copilot Chat" })
map("n", "<leader>e", "<cmd>Neotree toggle filesystem left<cr>", { desc = "󰙅 Toggle Explorer" })
map("n", "<leader>o", focus_neotree, { desc = "󰙅 Focus Explorer" })

map("n", "-", "<cmd>Neotree toggle filesystem left<cr>", { desc = "󰙅 Toggle File Explorer" })
map("n", "<leader>ff", pick.find_files, { desc = "󰈞 Find Files" })
map(
  "n",
  "<leader>fF",
  function() pick.find_files { hidden = true } end,
  { desc = "󰈞 Find Hidden Files" }
)
map("n", "<leader>fw", pick.live_grep, { desc = "󰍉 Find Text" })
map(
  "n",
  "<leader>fW",
  function() pick.live_grep { hidden = true } end,
  { desc = "󰍉 Find Hidden Text" }
)

map("n", "gl", vim.diagnostic.open_float, { desc = " Line Diagnostics" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = " Line Diagnostics" })
map("n", "<C-w>d", vim.diagnostic.open_float, { desc = " Line Diagnostics" })
map("n", "<leader>lI", "<cmd>ConformInfo<cr>", { desc = " Conform Info" })
map("n", "<leader>lD", function() pick.diagnostics "current" end, { desc = "󰒡 All Diagnostics" })
map("n", "<leader>lw", function() pick.diagnostics "all" end, { desc = "󰒡 Workspace Diagnostics" })
map("n", "[d", diagnostic_jump(-1), { desc = " Diagnostic Previous" })
map("n", "]d", diagnostic_jump(1), { desc = " Diagnostic Next" })
map("n", "[e", diagnostic_jump(-1, vim.diagnostic.severity.ERROR), { desc = " Error Previous" })
map("n", "]e", diagnostic_jump(1, vim.diagnostic.severity.ERROR), { desc = " Error Next" })
map("n", "[w", diagnostic_jump(-1, vim.diagnostic.severity.WARN), { desc = " Warning Previous" })
map("n", "]w", diagnostic_jump(1, vim.diagnostic.severity.WARN), { desc = " Warning Next" })
map("n", "<leader>uH", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "󰞋 Toggle LSP Inlay Hints" })

map("n", "<leader>gy", function()
  local file = vim.api.nvim_buf_get_name(0)
  local result = vim.system({ "git", "diff", "-U5", "HEAD", "--", file }, { text = true }):wait()
  local diff = result.stdout or ""

  if result.code ~= 0 or diff == "" then
    vim.notify("No changes found", vim.log.levels.INFO)
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

  local markdown_diff = "```diff\n" .. table.concat(lines, "\n") .. "\n```"
  vim.fn.setreg("+", markdown_diff)
  vim.notify("Git diff copied to clipboard", vim.log.levels.INFO)
end, { desc = "Copy git diff to clipboard (markdown)" })
