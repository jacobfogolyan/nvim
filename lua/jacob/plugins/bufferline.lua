return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	event = {
		"VeryLazy",
	},
	keys = {
		{ "<C-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
		{ "<C-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
	},
	config = function()
		require("bufferline").setup {

		}
	end
}
