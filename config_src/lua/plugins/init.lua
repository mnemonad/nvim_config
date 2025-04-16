return {
    {
        "nvim-lua/plenary.nvim",
        name = "plenary",
    },
	{
		"EdenEast/nightfox.nvim",
		name = "nightfox",
		config = function()
			vim.cmd("colorscheme nightfox")
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
