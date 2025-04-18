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
		require("bufferline").setup {}

		vim.api.nvim_create_user_command("Fp", function()
			local current_buffer = vim.api.nvim_get_current_buf()
			local buffer_name = vim.api.nvim_buf_get_name(current_buffer)
			vim.api.nvim_echo({ { tostring(buffer_name), "Normal" } }, false, {})
		end, {})

		vim.api.nvim_create_user_command("CopyFp", function()
			local current_buffer = vim.api.nvim_get_current_buf()
			local buffer_name = vim.api.nvim_buf_get_name(current_buffer)
			vim.fn.setreg('+', buffer_name)
			local message = "Copied buffer name to clipboard: " .. tostring(buffer_name)
			vim.api.nvim_echo({ { message, "Normal" } }, false, {})
		end, {})
	end
}
