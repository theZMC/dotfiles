local buffers = require "config.buffers"

local map = vim.keymap.set

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

map("n", "]b", function() buffers.cycle(1, vim.v.count1) end, { desc = "Next buffer" })

map("n", "[b", function() buffers.cycle(-1, vim.v.count1) end, { desc = "Previous buffer" })

map("n", "<leader>c", buffers.close_current, { desc = "Close current buffer" })
map("n", "<leader>bd", buffers.pick_to_close, { desc = "Close buffer" })
map("n", "<leader>cf", "<cmd>Format<cr>", { desc = "Format buffer" })
map("n", "<leader>q", "<cmd>confirm qall<cr>", { desc = "Quit Neovim" })
map("n", "<leader>tt", function() require("config.terminal").toggle() end, { desc = "Toggle terminal" })
map("n", "<leader>gg", function() require("config.terminal").lazygit() end, { desc = "LazyGit" })
map("n", "<leader>ac", "<cmd>CopilotChatToggle<cr>", { desc = "Copilot Chat" })
map("n", "<leader>e", "<cmd>Neotree toggle filesystem left<cr>", { desc = "Toggle Neo-tree" })
map("n", "<leader>o", focus_neotree, { desc = "Focus Neo-tree" })

map("n", "-", "<cmd>Neotree toggle filesystem left<cr>", { desc = "Toggle file explorer" })
map("n", "<leader>ff", function() require("telescope.builtin").find_files() end, { desc = "Find files" })
map(
  "n",
  "<leader>fF",
  function() require("telescope.builtin").find_files { hidden = true } end,
  { desc = "Find hidden files" }
)
map("n", "<leader>fw", function() require("telescope.builtin").live_grep() end, { desc = "Find text" })
map(
  "n",
  "<leader>fW",
  function() require("telescope.builtin").live_grep { hidden = true } end,
  { desc = "Find hidden text" }
)

map("n", "[d", function() vim.diagnostic.jump { count = -1, float = true } end, { desc = "Previous diagnostic" })

map("n", "]d", function() vim.diagnostic.jump { count = 1, float = true } end, { desc = "Next diagnostic" })

map("n", "<leader>de", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

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
