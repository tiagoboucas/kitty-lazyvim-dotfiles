-- Omarchy theme for Neovim — ported 1:1 from
-- omacom/omarchy → themes/tokyo-night/neovim.lua
return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}
