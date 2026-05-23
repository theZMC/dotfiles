# nvim-next

Custom Neovim config that keeps the useful parts of `../nvim` while leaning on
Neovim 0.12 built-ins wherever core now has a good answer.

## Native-first choices

- `vim.pack` instead of `lazy.nvim`
- `vim.lsp.config()` and `vim.lsp.enable()` instead of
  `require("lspconfig").setup()`
- Built-in diagnostics instead of Astro diagnostic wrappers
- Built-in `vim.ui.select()` for buffer picking
- Small floating terminal helper instead of `toggleterm.nvim`

## Plugins kept

These stay because core still does not replace them cleanly yet:

- `neovim/nvim-lspconfig`: ships the runtime `lsp/*.lua` configs
- `nvim-treesitter/nvim-treesitter`: parser management + query distribution for
  Neovim's built-in treesitter features
- `stevearc/conform.nvim`: external formatter orchestration
- `cpea2506/one_monokai.nvim`: colorscheme parity with your current setup
- `zbirenbaum/copilot.lua`
- `rcarriga/nvim-notify`: top-right notification popups
- `folke/noice.nvim`: message UI and centered command line popup
- `nvim-neo-tree/neo-tree.nvim`: file explorer sidebar
- `nvim-telescope/telescope.nvim`: fuzzy finding for files and text search
- `CopilotC-Nvim/CopilotChat.nvim`
- `MeanderingProgrammer/render-markdown.nvim`

## Layout

- `lua/config/plugins/`: `vim.pack` setup plus general plugin configuration
- `lua/config/languages/`: per-language LSP and formatting configuration

## External tools this config expects

- LSPs you actually use, for example: `lua-language-server`,
  `bash-language-server`, `gopls`, `clangd`, `basedpyright`, `ruff`, `marksman`,
  `yaml-language-server`, `terraform-ls`
- Formatters matching your old config: `deno`, `yamlfmt`, `hclfmt`
- Search tooling for Telescope live grep: `ripgrep`
- Treesitter prerequisites if you want parser auto-install: `tree-sitter`,
  `curl`, `tar`, and a C compiler

## LuaLS for this repo

- Project-local LuaLS settings live in `.luarc.json`
- That file points LuaLS at the Neovim 0.12 runtime from `mise` plus the plugins
  installed for `NVIM_APPNAME=nvim-next`
- This keeps completion and navigation working even when you edit `nvim-next`
  from a different Neovim config, like your current 0.11 setup
- If you add another Lua plugin in `lua/config/plugins/pack.lua`, add its installed path
  under `workspace.library` in `.luarc.json`

## Useful commands

- `:PackUpdate` updates plugins managed by `vim.pack`
- `:LazyGit` opens `lazygit` in a floating terminal
- `:Format` formats the current buffer

## Keymaps carried over or replaced natively

- `]b` / `[b`: next / previous buffer
- `<leader>c`: close current buffer
- `<leader>bd`: pick a buffer to close
- `<leader>cf`: format buffer
- `<leader>q`: quit Neovim
- `<leader>gg`: open `lazygit`
- `<leader>tt`: toggle floating terminal
- `<leader>ac`: toggle Copilot Chat
- `<leader>e`: toggle Neo-tree
- `<leader>o`: jump between current buffer and Neo-tree, opening and revealing
  if needed
- `<leader>ff`: fuzzy find files
- `<leader>fF`: fuzzy find hidden files too
- `<leader>fw`: live grep file contents
- `<leader>fW`: live grep hidden file contents too
- `<leader>lR`: Telescope picker for symbol references
- `<leader>de`: line diagnostics
- `<leader>dq`: diagnostics to loclist
- `<leader>gy`: copy current-file git diff as fenced markdown
- `-`: toggle file explorer
