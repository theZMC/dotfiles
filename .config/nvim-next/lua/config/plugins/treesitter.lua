local ok, treesitter = pcall(require, "nvim-treesitter")

if not ok then return end

local languages = {
  "astro",
  "bash",
  "c",
  "cpp",
  "css",
  "diff",
  "dockerfile",
  "go",
  "gomod",
  "gowork",
  "helm",
  "html",
  "java",
  "javascript",
  "json",
  "jsonc",
  "lua",
  "markdown",
  "markdown_inline",
  "proto",
  "python",
  "query",
  "rust",
  "svelte",
  "terraform",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
}

treesitter.setup {
  install_dir = vim.fn.stdpath "data" .. "/site",
}

local available = {}
for _, lang in ipairs(treesitter.get_available()) do
  available[lang] = true
end

local wanted = {}
for _, lang in ipairs(languages) do
  if available[lang] then table.insert(wanted, lang) end
end

if vim.fn.executable "tree-sitter" == 1 then
  local installed = {}
  for _, lang in ipairs(treesitter.get_installed()) do
    installed[lang] = true
  end

  local missing = {}
  for _, lang in ipairs(wanted) do
    if not installed[lang] then table.insert(missing, lang) end
  end

  if #missing > 0 then treesitter.install(missing) end
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
  desc = "Enable treesitter highlighting when a parser exists",
  callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})
