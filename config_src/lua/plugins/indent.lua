return {
    -- Automatically detect indent settings from file
    {
        "tpope/vim-sleuth",
    },

    -- Show indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "BufReadPost",
        opts = {
            indent = {
                char = "│",
            },
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
            },
            exclude = {
                filetypes = { "help", "lazy", "mason", "notify", "toggleterm" },
            },
        },
    },
}
