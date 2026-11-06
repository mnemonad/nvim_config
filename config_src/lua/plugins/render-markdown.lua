return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'markdown' },
    opts = {},
    keys = {
        { '<leader>rm', '<cmd>RenderMarkdown toggle<cr>', desc = 'Toggle Markdown Render' },
    },
}
