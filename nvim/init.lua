-- Disable unused providers (speeds up startup)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "macchiato" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    -- Parsers installed via :TSInstall or build = ":TSUpdate"
    -- Highlighting uses default vim syntax; treesitter used for textobjects only
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })
      local select = require("nvim-treesitter-textobjects.select")
      local map = function(key, query)
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end)
      end
      map("af", "@function.outer")
      map("if", "@function.inner")
      map("ac", "@class.outer")
      map("ic", "@class.inner")
      map("aa", "@parameter.outer")
      map("ia", "@parameter.inner")
    end,
  },
})
