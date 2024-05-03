return {
    "akinsho/bufferline.nvim",
    version = "*",
    -- dependencies only for this catppuccin theme, these will be loaded before plugin is loaded
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "catppuccin/nvim",
    },
    event = {
        "VeryLazy",
    },
    after = "catppuccin",
    keys = {
        { "<C-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
        { "<C-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    config = function ()
        require("bufferline").setup {
            highlights = require("catppuccin.groups.integrations.bufferline").get(),
            options = {
                mode = "buffers",
                separator_style = "slant",
                show_buffer_icons = true,
                show_tab_indicators = true,
                show_close_icon = false,
                show_buffer_close_icons = false,
                always_show_bufferline = false,
                indicator = {
                    style = "underline",
                },
            },
        }
    end
}
