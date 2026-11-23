-- loaded as initLua by home/editors.nix, the plugins come from nixpkgs

vim.g.mapleader = " "

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.laststatus = 3
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 300

-- habits from the old init.vim
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("n", "<C-s>", "<Cmd>write<CR>", { desc = "Save" })
vim.keymap.set("n", "<M-Left>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<M-Right>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "++", "gcc", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "++", "gc", { remap = true, desc = "Toggle comment" })

require("plugins")
