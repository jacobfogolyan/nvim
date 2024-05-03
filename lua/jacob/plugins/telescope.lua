return {
	"nvim-telescope/telescope.nvim",
	tag = '0.1.6',
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local telescope = require("telescope")
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")
		local trouble = require("trouble.providers.telescope")

		telescope.setup {
			-- extra setup options, integrate with other plugins etc
			--
			defaults = {
				mappings = {
					i = {
						["<C-t>"] = trouble.open_with_trouble,
					},
					n = {
						["<C-q"] = actions.smart_send_to_qflist + actions.open_qflist,
						["<C-t>"] = trouble.open_with_trouble,
						["q"] = actions.close,
					},
				}
			}
		}

		local function customFindFiles()
			builtin.find_files({
				find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
				previewer = false,
			})
		end

        -- Open telescope to neovim configuration directory.
        -- Autocmd must start with upper case letter.
        vim.api.nvim_create_user_command("Config", function ()
            builtin.find_files({cwd="~/.config/nvim"})
        end, {})

		vim.keymap.set("n", "<leader>f", customFindFiles, {})
		-- vim.keymap.set("n", "C-q", actions.smart_send_to_qflist + actions.open_qflist, {})
		vim.keymap.set("n", "<leader>F", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>b", builtin.buffers, {})
		vim.keymap.set("n", "<C-k>", "<C-p>")
	end
}
