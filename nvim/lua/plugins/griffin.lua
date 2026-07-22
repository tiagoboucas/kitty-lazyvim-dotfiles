return {
  -- add the griffin.nvim colorscheme
  { "Griffin38/griffin.nvim" },

  -- Configure LazyVim to load griffin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "griffin",
    },
  },

  -- use the bundled griffin lualine theme
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "griffin",
      },
    },
  },
}
