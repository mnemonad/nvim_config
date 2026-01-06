return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function()
        require("codecompanion").setup({
            strategies = {
                chat = { adapter = "anthropic" },
                inline = { adapter = "anthropic" },
                agent = { adapter = "anthropic" },
            },
            adapters = {
                anthropic = function()
                    return require("codecompanion.adapters").extend("anthropic", {
                        schema = {
                            model = {
                                default = "claude-sonnet-4-20250514",
                            },
                        },
                    })
                end,
            },
            display = {
                chat = {
                    window = {
                        layout = "vertical",
                        width = 0.4,
                    },
                },
            },
        })

        -- Keymaps
        vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle chat" })
        vim.keymap.set("v", "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add to chat" })
        vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Actions menu" })
        vim.keymap.set("v", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "Actions menu" })
        vim.keymap.set("v", "<leader>ae", "<cmd>CodeCompanion<cr>", { desc = "Inline edit" })
    end,
}
