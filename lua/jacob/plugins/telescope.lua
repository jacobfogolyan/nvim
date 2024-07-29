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
				},
				layout_strategy = "vertical",
				layout_config = {
					vertical = {
						preview_height = 0.5,
						results_height = 0.5,
					},
					height = 0.9,
					width = 0.9,
				}
			},
		}

		local function customFindFiles()
			builtin.find_files({
				-- TODO: revisit this
				file_ignore_patterns = {
					-- VCS source directories
					".git/",
					-- Go packages
					"vendor/",
					-- JS packages
					"node_modules/",
					-- Vim files
					"*~",
					"*.swp",
					"*.swo",
					".yarn/",
				},
				find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
				-- find_command = { 'rg', '--files', '--hidden', '--glob', '**/.env', '--glob', '*' },

				previewer = false,
			})
		end

		-- Open telescope to neovim configuration directory.
		-- Autocmd must start with upper case letter.
		vim.api.nvim_create_user_command("Config", function()
			builtin.find_files({ cwd = "~/.config/nvim" })
		end, {})

		vim.keymap.set("n", "<leader>f", customFindFiles, {})
		-- vim.keymap.set("n", "C-q", actions.smart_send_to_qflist + actions.open_qflist, {})
		vim.keymap.set("n", "<leader>F", builtin.live_grep, {})
		-- list buffers
		vim.keymap.set("n", "<leader>b", builtin.buffers, {})
		-- Registers
		vim.keymap.set("n", "<leader>r", builtin.registers, {})
		-- vim.keymap.set("q", "<leader>q", builtin.
		vim.keymap.set("n", "<C-k>", "<C-p>")
	end
}
