return {
  { "catppuccin/nvim", name = "catppuccin", opts = { flavour = "mocha" } },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
  {
    "folke/zen-mode.nvim",
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
    opts = {
      window = { width = 60 },
      plugins = {
        options = { number = false, relativenumber = false, laststatus = 0 },
      },
      on_open = function()
        vim.wo.wrap = true
        vim.wo.linebreak = true
      end,
      on_close = function()
        vim.wo.wrap = false
        vim.wo.linebreak = false
      end,
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        menu = { auto_show = false },
      },
    },
  },
}
