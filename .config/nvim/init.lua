-- local map = vim.keymap.set
-- local opts = { noremap = true, silent = true }

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Save undo history
vim.o.undofile = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = 'unnamedplus'
end)

-- Copy to clipboard shortcuts
vim.keymap.set('n', '<leader>cp', function()
	local path = vim.fn.expand('%:p')
	vim.fn.setreg('+', path)
	vim.notify('Copied: ' .. path)
end, { desc = 'Copy absolute path' })

vim.keymap.set('n', '<leader>cr', function()
	local path = vim.fn.expand('%')
	vim.fn.setreg('+', path)
	vim.notify('Copied: ' .. path)
end, { desc = 'Copy relative path' })

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Snappy escape
vim.o.ttimeoutlen = 1

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Vim diagnostics
vim.diagnostic.config({
	severity_sort = true,    -- show most severe error first
	update_in_insert = false, -- don't update while typing
	float = { source = 'if_many' }, -- nicer look for floats and show source if multiple sources (ex. ruff and ty)
	jump = { float = true }, -- automatically open the diagnostic float if you jump with [d ]d
})

-- Show diagnostics
vim.keymap.set('n', '<leader>D', vim.diagnostic.open_float, { desc = 'Show diagnostics' })

-- Easily move between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight yanks
vim.api.nvim_create_autocmd('TextYankPost', {
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function() vim.highlight.on_yank() end,
})

-- Plugins
-- Pack guide: https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack#update
vim.pack.add({
	'https://github.com/ibhagwan/fzf-lua',
	'https://github.com/nvim-treesitter/nvim-treesitter',
	'https://github.com/neovim/nvim-lspconfig',
	'https://github.com/karb94/neoscroll.nvim',
	'https://github.com/mfussenegger/nvim-dap',
	'https://github.com/stevearc/oil.nvim',
	'https://github.com/kdheepak/lazygit.nvim',
	'https://github.com/esmuellert/codediff.nvim',
	'https://github.com/MeanderingProgrammer/render-markdown.nvim',
	'https://github.com/kepano/flexoki-neovim',
	'https://github.com/NMAC427/guess-indent.nvim',
	'https://github.com/lukas-reineke/indent-blankline.nvim',
	{ src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') }, -- pinning so rust binary dependency automatically downloads
})


-- FzfLua Setup
local fzf = require('fzf-lua')
fzf.setup({
	keymap = {
		builtin = {
			["<C-d>"] = 'preview-page-down', -- Better scrolling within the displays
			["<C-u>"] = 'preview-page-up',
		},
	},
	winopts = {
		height  = 0.95, -- window height
		width   = 0.90, -- window width
		preview = {
			layout   = 'vertical',
			vertical = "down:30%",
		}
	},
	files = {
		formatter = 'path.filename_first',
	},
})

vim.keymap.set('n', '<leader><leader>', '<cmd>FzfLua files<cr>', { desc = 'Find files' })
vim.keymap.set('n', '<leader>/', '<cmd>FzfLua live_grep<cr>', { desc = 'Find live grep' })
vim.keymap.set('n', '<leader>fr', '<cmd>FzfLua resume<cr>', { desc = 'Resume last picker' })
vim.keymap.set('n', '<leader>,', '<cmd>FzfLua buffers<cr>', { desc = 'Buffers' })

vim.keymap.set('n', 'grr', fzf.lsp_references, { desc = 'References' })
vim.keymap.set('n', 'gri', fzf.lsp_implementations, { desc = 'Implementations' })
vim.keymap.set('n', 'gra', fzf.lsp_code_actions, { desc = 'Code actions' })


-- Treesitter
vim.cmd('syntax off') -- Make it obvious if treesitter is missing
vim.api.nvim_create_autocmd('FileType', {
	callback = function() pcall(vim.treesitter.start) end,
})


-- LSP
vim.lsp.enable({
	'ty',            -- also $ uv tool install ty@latest
	'ruff',          -- also $ uv tool install ruff@latest
	'lua_ls'         -- also $ brew install lua-language-server
})
vim.o.signcolumn = 'yes' -- make lsp warnings not widen the gutter
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
-- Auto-format ("lint") on save (adapted from neovim docs :help auto-format)
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', { clear = true }),
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		if not client:supports_method('textDocument/willSaveWaitUntil')
		    and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('my.lsp.fmt', { clear = false }),
				buffer = ev.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
				end,
			})
		end
	end,
})


-- Blink.cmp
require('blink.cmp').setup({
	keymap = {
		preset = "enter",
	}
})


-- Neoscroll
require('neoscroll').setup({
	hide_cursor = false,
	stop_eof = true,
	easing = 'quadratic',
	duration_multiplier = 0.30,
})


-- Dap (debugging)
local dap = require('dap')
dap.adapters.debugpy = function(cb, config) -- also $ uv tool install debugpy@latest
	if config.request == 'attach' then
		cb({
			type = 'server',
			port = config.connect.port,
			host = config.connect.host or '127.0.0.1',
		})
	else
		cb({
			type = 'executable',
			command = 'debugpy-adapter',
		})
	end
end
dap.configurations.python = { -- https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
	{
		type = 'debugpy',
		request = 'launch',
		name = 'Launch file',
		program = '${file}',
		python = function()
			local root = vim.fs.root(0, '.venv')
			return { root and root .. '/.venv/bin/python' or 'python3' }
		end,
		cwd = function()
			return vim.fs.root(0, '.venv') or vim.fn.getcwd()
		end,
	},
}
-- vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug toggle breakpoint' })
-- vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug continue' })
-- vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = 'Debug terminate' })
-- vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug open REPL' })
-- vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug run last' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>dh', require('dap.ui.widgets').hover, { desc = 'Debug hover' })
-- vim.keymap.set('n', '<Down>', dap.step_over, { desc = 'Debug step over' })
-- vim.keymap.set('n', '<Right>', dap.step_into, { desc = 'Debug step into' })
-- vim.keymap.set('n', '<Left>', dap.step_out, { desc = 'Debug step out' })
-- vim.keymap.set('n', '<Up>', dap.restart_frame, { desc = 'Debug restart frame' })


-- Oil.nvim
require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })


-- Lazygit.nvim
vim.keymap.set('n', '<leader>g', '<cmd>LazyGit<cr>', { desc = 'Lazygit' })


-- Codediff (vscode like diffs :))
require("codediff").setup({})
vim.keymap.set('n', '<leader>ru', '<cmd>CodeDiff<cr>', { desc = 'Code diff not staged' })
vim.keymap.set('n', '<leader>rm', '<cmd>CodeDiff main<cr>', { desc = 'Code diff main' })
vim.keymap.set('n', '<leader>rh', '<cmd>CodeDiff HEAD~1<cr>', { desc = 'Code diff previous commit' })


-- Markdown
require('render-markdown').setup({})


-- Flexoki
require('flexoki').setup({})
vim.cmd('colorscheme flexoki-dark') -- need to call after setup
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })


-- guess-indent
require('guess-indent').setup({})


-- indent-blankline
require('ibl').setup({})
