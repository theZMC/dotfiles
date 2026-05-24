local function github(repo)
  return {
    src = ("https://github.com/%s"):format(repo),
    name = repo:match "/([^/]+)$",
  }
end

local plugins = {
  github "neovim/nvim-lspconfig",
  github "nvim-treesitter/nvim-treesitter",
  github "stevearc/conform.nvim",
  github "cpea2506/one_monokai.nvim",
  github "zbirenbaum/copilot.lua",
  github "nvim-lua/plenary.nvim",
  github "nvim-tree/nvim-web-devicons",
  github "aserowy/tmux.nvim",
  github "akinsho/toggleterm.nvim",
  github "MunifTanjim/nui.nvim",
  github "rcarriga/nvim-notify",
  github "nvim-mini/mini.tabline",
  github "nvim-mini/mini.clue",
  github "nvim-mini/mini.pick",
  github "nvim-mini/mini.extra",
  github "folke/noice.nvim",
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    name = "neo-tree.nvim",
    version = vim.version.range "3",
  },
  github "CopilotC-Nvim/CopilotChat.nvim",
  github "MeanderingProgrammer/render-markdown.nvim",
}

vim.pack.add(plugins, {
  confirm = false,
})

for _, plugin in ipairs(plugins) do
  vim.cmd(("packadd %s"):format(plugin.name))
end
