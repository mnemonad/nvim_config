return {
    {
        "nvim-lua/plenary.nvim",
        name = "plenary",
    },
	{
		"EdenEast/nightfox.nvim",
		name = "nightfox",
		config = function()
			-- Use TTY-compatible colorscheme when in Linux console
			if os.getenv("TERM") == "linux" then
				vim.cmd("colorscheme slate")
			else
				vim.cmd("colorscheme nightfox")
			end
		end,
	},

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "plenary" },
    },

	{
		"folke/trouble.nvim",
		config = function()
			require("trouble").setup {
				icons = false,
			}
		end,
	},

    --[[
	{
		"nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
	}
    --]]
}
