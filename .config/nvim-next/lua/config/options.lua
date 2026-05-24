vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

local opt = vim.opt

local function helm_filetype(path)
  if not vim.fs.find("Chart.yaml", { path = vim.fs.dirname(path), type = "file", upward = true })[1] then return end

  if path:match "/templates/" then return "helm" end
  if path:match "/values[^/]*%.ya?ml$" then return "yaml.helm-values" end
end

vim.filetype.add {
  extension = {
    gotmpl = "gotmpl",
  },
  pattern = {
    [".*/templates/.*%.ya?ml"] = { helm_filetype, { priority = 10 } },
    [".*/templates/.*%.tpl"] = { helm_filetype, { priority = 10 } },
    [".*/templates/.*%.txt"] = { helm_filetype, { priority = 10 } },
    [".*/values[^/]*%.ya?ml"] = { helm_filetype, { priority = 10 } },
  },
}

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.spell = false
opt.wrap = false

opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.expandtab = true

opt.termguicolors = true
opt.clipboard:append "unnamedplus"
opt.completeopt = { "menu", "menuone", "popup", "noinsert" }
opt.winborder = "rounded"
opt.fillchars:append { eob = " " }
