return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        delay = 300,
        icons = {
            mappings = false,
        },
        spec = {
            { "<leader>p", group = "project/files" },
            { "<leader>v", group = "vim" },
            { "<leader>a", group = "avante/ai" },
        },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps",
        },
    },
}
