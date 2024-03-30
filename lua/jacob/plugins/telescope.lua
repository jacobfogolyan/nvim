return {
	"nvim-telescope/telescope.nvim",
	tag = '0.1.6',
	config = function()
		local telescope = require("telescope")
		telescope.setup {
			-- extra setup options, integrate with other plugins etc	
		}
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>f", builtin.find_files, {})
		-- <C-f> needs ripgrep
		vim.keymap.set("n", "<C-f>", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>b", builtin.buffers, {})
	end
}
