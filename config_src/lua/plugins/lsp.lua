return {
    "neovim/nvim-lspconfig",

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
    },

    config = function()
        local cmp = require("cmp")
        local cmp_lsp = require("cmp_nvim_lsp")
        -- Fixed: Changed 'capabilites' to 'capabilities'
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        cmp.setup({
            sources = {
                { name = "nvim_lsp" },
            },
            snippet = {
                expand = function(args)
                    vim.snippet.expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({}),
        })

        require("mason").setup()

        -- mason-lspconfig removed its handlers option: servers take their config from here.
        vim.lsp.config("*", { capabilities = capabilities })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "pyright",
                "bashls",
                "yamlls",
                "marksman",
                "buf_ls",
                "elixirls",
            },
        })

        -- Needs Elixir on PATH: mason's elixir-ls is a launcher that compiles the server on first start.
        vim.lsp.config("elixirls", {
            settings = {
                elixirLS = {
                    dialyzerEnabled = false,
                    fetchDeps = false,
                },
            },
        })
    end,
}
