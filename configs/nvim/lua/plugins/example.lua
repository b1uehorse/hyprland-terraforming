return {
  { "catppuccin/nvim", name = "catppuccin", opts = { flavour = "mocha" } },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
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
