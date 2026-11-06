-- The main branch, which Neovim 0.12 needs (master stops at 0.11). It needs the
-- tree-sitter CLI and a C compiler; install_tools.sh checks for both.
vim.g.treesitter_parsers = { "c", "lua", "rust", "python", "svelte", "html", "javascript", "css",
    "bash", "yaml", "markdown", "markdown_inline", "elixir", "heex", "eex", "proto" }

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    config = function()
        -- A no-op for parsers already installed.
        require("nvim-treesitter").install(vim.g.treesitter_parsers)

        -- main doesn't start highlighting by itself. get_lang() lacks a mapping for
        -- some filetypes (rust, for one), so fall back to the filetype's own name.
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(ev)
                local filetype = vim.bo[ev.buf].filetype
                local lang = vim.treesitter.language.get_lang(filetype) or filetype
                if lang ~= "" and pcall(vim.treesitter.language.add, lang) then
                    pcall(vim.treesitter.start, ev.buf, lang)
                end
            end,
        })
    end,
}
