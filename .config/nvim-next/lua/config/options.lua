vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.spell = false
opt.wrap = false

opt.termguicolors = true
opt.clipboard:append "unnamedplus"
opt.completeopt = { "menu", "menuone", "popup", "noinsert" }
opt.winborder = "rounded"
opt.fillchars:append { eob = " " }
