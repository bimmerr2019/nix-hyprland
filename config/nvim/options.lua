local opt = vim.opt
local prefix = vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.mouse = "a"
opt.cursorline = true
opt.backspace = "indent,eol,start"
opt.clipboard:append("unnamedplus")
opt.splitright = true
opt.splitbelow = true
opt.swapfile = false
vim.g.mapleader = " "
-- get undo working
opt.undofile = true
opt.undodir = { prefix .. "/nvim/.undo//" }
opt.undolevels = 10000
opt.undoreload = 10000
