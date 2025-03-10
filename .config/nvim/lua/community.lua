-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.colorscheme.monokai-pro-nvim" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  {
    import = "astrocommunity.diagnostics.tiny-inline-diagnostic-nvim",
    "rachartier/tiny-inline-diagnostic.nvim",
    opts = {
      preset = "minimal",
      options = {
        multilines = true,
        show_source = true,
      },
    },
  },
  { import = "astrocommunity.docker.lazydocker" },
  { import = "astrocommunity.editing-support.refactoring-nvim" },
  {
    import = "astrocommunity.editing-support.copilotchat-nvim",
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      model = "claude-3.5-sonnet",
      window = {
        layout = "float",
      },
    },
  },
  { import = "astrocommunity.file-explorer.oil-nvim" },
  { import = "astrocommunity.game.leetcode-nvim" },
  { import = "astrocommunity.git.blame-nvim" },
  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.git.gitgraph-nvim" },
  { import = "astrocommunity.lsp.ts-error-translator-nvim" },
  { import = "astrocommunity.lsp.actions-preview-nvim" },
  { import = "astrocommunity.markdown-and-latex.peek-nvim" },
  { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  -- { import = "astrocommunity.markdown-and-latex.markview-nvim" },
  { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.pack.astro" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.cs" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.helm" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.java" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.php" },
  -- { import = "astrocommunity.pack.proto" },
  { import = "astrocommunity.pack.ps1" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.svelte" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.typescript-all-in-one" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.recipes.astrolsp-no-insert-inlay-hints" },
  { import = "astrocommunity.recipes.telescope-lsp-mappings" },
  { import = "astrocommunity.recipes.vscode" },
  {
    import = "astrocommunity.test.neotest",
    -- "nvim-neotest/neotest",
    -- dependencies = {
    --   "marilari88/neotest-vitest",
    --   "thenbe/neotest-playwright",
    -- },
    -- opts = function(_, opts)
    --   if not opts.adapters then opts.adapters = {} end
    --   table.insert(opts.adapters, require "neotest-vitest"(require("astrocore").plugin_opts "neotest-vitest"))
    --   table.insert(opts.adapters, require "neotest-playwright"(require("astrocore").plugin_opts "neotest-playwright"))
    -- end,
  },
  { import = "astrocommunity.test.nvim-coverage" },
}
