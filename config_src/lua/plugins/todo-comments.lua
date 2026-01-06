return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {
        signs = true,
        keywords = {
            FIX = { icon = "F", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
            TODO = { icon = "T", color = "info" },
            HACK = { icon = "H", color = "warning" },
            WARN = { icon = "W", color = "warning", alt = { "WARNING", "XXX" } },
            PERF = { icon = "P", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = "N", color = "hint", alt = { "INFO" } },
        },
        highlight = {
            before = "",
            keyword = "wide",
            after = "fg",
        },
    },
    keys = {
        { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
        { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
        { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search todos" },
    },
}
