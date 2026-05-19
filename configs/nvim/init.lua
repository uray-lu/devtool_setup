-- Leader key (Spacebar)
vim.g.mapleader = " "

-- Sync with system clipboard
vim.opt.clipboard = "unnamedplus"

-- Line numbers & syntax highlighting
vim.opt.number = true
vim.opt.syntax = "on"

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- Treesitter: precise syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "html", "css", "json", "bash" },
        highlight = { enable = true },
      })
    end,
  },

  -- File explorer sidebar
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- LSP config for error diagnostics
  {
    "neovim/nvim-lspconfig",
  },
})

-- Keybindings
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Explorer" })

-- Colorscheme (change to your preference: torte, habamax, retrobox, etc.)
vim.cmd.colorscheme("habamax")
