-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
  },
  {
    'numToStr/Comment.nvim',
    opts = {},
  },
  {
    'kawre/leetcode.nvim',
    build = ':TSUpdate html', -- if you have `nvim-treesitter` installed
    dependencies = {
      -- include a picker of your choice, see picker section for more details
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      -- configuration goes here
      ---@type lc.storage
      storage = {
        home = vim.fn.stdpath 'data' .. '/leetcode',
        cache = vim.fn.stdpath 'cache' .. '/leetcode',
      },
    },
  },
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = 'skim'
    end,
  },
  {
    'iurimateus/luasnip-latex-snippets.nvim',
    dependencies = {
      'L3MON4D3/LuaSnip',
      -- "lervag/vimtex",
    },
    config = function()
      require('luasnip-latex-snippets').setup {
        use_treesitter = true,
      }
      require('luasnip').config.setup { enable_autosnippets = true }
    end,
  },
}
