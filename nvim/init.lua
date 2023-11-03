vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.opt.encoding = "utf-8"
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.scrolloff = 8
vim.o.wrap = false
vim.o.visualbell = true
vim.o.guicursor = "n-v-c:block-Cursor"
vim.o.incsearch = true
vim.o.updatetime = 50
vim.o.termguicolors = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.cmd([[
set mouse=
]])
vim.o.mouse = false
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true }) --to keep the page centered when using ctrl d
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true }) --to keep the page centered when using ctrl u
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.api.nvim_set_var("Hexokinase_highlighters", { "virtual" })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,

	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",

			timeout = 40,
		})
	end,
})

--lazy plugin manager

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local opts = {}

local plugins = {
	{ "ThePrimeagen/vim-be-good" },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		-- or                              , branch = '0.1.x',
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	{ "numToStr/Comment.nvim", config = true },
	{ "windwp/nvim-autopairs", config = true },
	{ "ThePrimeagen/harpoon" },
	{ "mbbill/undotree" },
	{ "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
	{ "folke/neodev.nvim" },
	{
		"nvim-lualine/lualine.nvim",
		config = true,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"folke/tokyonight.nvim",
		priority = 100,
		config = function()
			require("tokyonight").setup({
				on_colors = function(colors)
					colors.bg = "#0f111a"
				end,
			})
			vim.cmd([[colorscheme tokyonight-night]])
		end,
	},
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}, config = true },
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-context",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			require("config.treesitter")
		end,
	},
	{
		"stevearc/conform.nvim",
		lazy = true,
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("config.formatting")
		end,
	},
	{
		"NvChad/nvim-colorizer.lua",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("colorizer").setup({
				filetypes = { "*" },
				user_default_options = {
					RGB = true, -- #RGB hex codes
					RRGGBB = true, -- #RRGGBB hex codes
					names = true, -- "Name" codes like Blue or blue
					RRGGBBAA = true, -- #RRGGBBAA hex codes
					AARRGGBB = true, -- 0xAARRGGBB hex codes
					rgb_fn = true, -- CSS rgb() and rgba() functions
					hsl_fn = true, -- CSS hsl() and hsla() functions
					css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
					css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
					mode = "virtualtext", -- Set the display mode.
					virtualtext = "■",
				},
				-- all the sub-options of filetypes apply to buftypes
				buftypes = {},
			})
			vim.api.nvim_create_user_command("ColorizerMode", function(opts)
				require("colorizer").setup({
					filetypes = { "*" },
					user_default_options = {
						RGB = true, -- #RGB hex codes
						RRGGBB = true, -- #RRGGBB hex codes
						names = true, -- "Name" codes like Blue or blue
						RRGGBBAA = true, -- #RRGGBBAA hex codes
						AARRGGBB = true, -- 0xAARRGGBB hex codes
						rgb_fn = true, -- CSS rgb() and rgba() functions
						hsl_fn = true, -- CSS hsl() and hsla() functions
						css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
						css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
						mode = opts.fargs[1], -- Set the display mode.
						virtualtext = "■",
					},
					-- all the sub-options of filetypes apply to buftypes
					buftypes = {},
				})
				vim.cmd.ColorizerToggle()
			end, {
				nargs = 1,
				complete = function(ArgLead, CmdLine, CursorPos)
					return { "foreground", "background", "virtualtext" }
				end,
			})
		end,
	},

	-- LSP Support
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		config = function()
			require("config.lsp")
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-calc" },
			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
		config = function()
			require("config.cmp")
		end,
	},
}

require("lazy").setup(plugins, opts)
require("config.autopairs")
require("config.harpoon")
require("config.undotree")
require("config.telescope")
