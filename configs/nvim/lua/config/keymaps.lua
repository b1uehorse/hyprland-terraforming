-- Theme toggle (<leader>tt)
-- Меняй темы здесь:
local dark_theme = "catppuccin-mocha"
local light_theme = "catppuccin-latte"

vim.keymap.set("n", "<leader>tt", function()
  if vim.g.colors_name == dark_theme then
    vim.cmd.colorscheme(light_theme)
  else
    vim.cmd.colorscheme(dark_theme)
  end
end, { desc = "Toggle dark/light theme" })

-- Colemak-DH: MNEI navigation (replaces HJKL)
local modes = { "n", "x", "o" }
for _, mode in ipairs(modes) do
  vim.keymap.set(mode, "m", "h", { desc = "Left" })
  vim.keymap.set(mode, "n", "j", { desc = "Down" })
  vim.keymap.set(mode, "e", "k", { desc = "Up" })
  vim.keymap.set(mode, "i", "l", { desc = "Right" })

  vim.keymap.set(mode, "h", "i", { desc = "Insert" })
  vim.keymap.set(mode, "H", "I", { desc = "Insert at BOL" })
  vim.keymap.set(mode, "k", "n", { desc = "Next search" })
  vim.keymap.set(mode, "K", "N", { desc = "Prev search" })
  vim.keymap.set(mode, "l", "e", { desc = "End of word" })
  vim.keymap.set(mode, "L", "E", { desc = "End of WORD" })
  vim.keymap.set(mode, "j", "m", { desc = "Mark" })
  vim.keymap.set(mode, "J", "M", { desc = "Join lines" })
end
