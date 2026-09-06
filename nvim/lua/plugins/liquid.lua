-- Shopify Liquid support (no official LazyVim extra).
-- Uses the language server bundled with the Shopify CLI: `shopify theme language-server`.
-- Requires the Shopify CLI on PATH (`shopify version`).
return {
  -- Treesitter grammar for Liquid syntax highlighting / textobjects
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "liquid" })
      end
    end,
  },

  -- Language server via the Shopify CLI (theme-check).
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        theme_check = {
          -- Prefer the CLI-bundled server so it always matches your Shopify CLI version.
          cmd = { "shopify", "theme", "language-server" },
          filetypes = { "liquid" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(".theme-check.yml", ".git")(fname) or util.path.dirname(fname)
          end,
        },
      },
    },
  },
}
