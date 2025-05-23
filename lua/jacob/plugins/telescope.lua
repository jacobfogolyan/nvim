return {
	"nvim-telescope/telescope.nvim",
	tag = '0.1.8',
	dependencies = {
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
		"folke/trouble.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")
		local open_with_trouble = require("trouble.sources.telescope").open

		local select_one_or_multi = function(prompt_bufnr)
			local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
			local multi = picker:get_multi_selection()
			if not vim.tbl_isempty(multi) then
				require('telescope.actions').close(prompt_bufnr)
				for _, j in pairs(multi) do
					if j.path ~= nil then
						vim.cmd(string.format('%s %s', 'edit', j.path))
					end
				end
			else
				require('telescope.actions').select_default(prompt_bufnr)
			end
		end


		telescope.setup {
			defaults = {
				mappings = {
					i = {
						["<C-t>"] = open_with_trouble,
						["<tab>"] = actions.toggle_selection + actions.move_selection_next,
						["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
						['<CR>'] = select_one_or_multi,
					},
					n = {
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
						["<C-t>"] = open_with_trouble,
						["q"] = actions.close,
						["<tab>"] = actions.toggle_selection + actions.move_selection_next,
						["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
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
			pickers = {
				find_files = {
					-- Telescope theme
					-- theme = "dropdown"
				}
			}
		}


		-- Load UI selection extension
		-- This extension allows neovim to use telescope based UI menus for rendering internal windows (i.e. lsp.buf
		-- when autocompleting LSP code actions).
		telescope.load_extension("ui-select")


		local function customFindFiles()
			builtin.find_files({
				-- TODO: revisit this
				file_ignore_patterns = {
					-- VCS source directories
					".git",
					-- Go packages
					"vendor/",
					-- JS packages
					"node_modules/*",
					-- Vim files
					"*~",
					"*.swp",
					"*.swo",
					".yarn/",
				},
				--				find_command = { 'rg', '--files', '--no-ignore', '--hidden' },
				find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/', '--glob', '!node_modules/*', '--glob', '!.yarn/*' },
				-- find_command = { 'rg', '--files', '--hidden', '--glob', '!.git/', '--glob', '!node_modules/*', '--glob', '!.yarn/*' },
				-- find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
				-- find_command = { 'rg', '--files', '--hidden', '--glob', '**/.env', '--glob', '*' },

				previewer = true,
				prompt_prefix = " "
			})
		end

		local function customLiveGrep()
			builtin.live_grep({
				-- TODO: revisit this
				file_ignore_patterns = {
					-- VCS source directories
					".git/",
					-- Go packages
					"vendor/",
					-- JS packages
					"node_modules/*",
					-- Vim files
					"*~",
					"*.swp",
					"*.swo",
					".yarn/",
				},
				find_command = { 'rg', '--files', '--hidden' },
				-- find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
				-- find_command = { 'rg', '--files', '--hidden', '--glob', '**/.env', '--glob', '*' },

				previewer = true,
				prompt_prefix = " "
			})
		end


		-- Open telescope to neovim configuration directory.
		-- Autocmd must start with upper case letter.
		vim.api.nvim_create_user_command("Config", function()
			builtin.find_files({ cwd = "~/.config/nvim" })
		end, {})

		vim.keymap.set("n", "<leader>f", customFindFiles, {})
		-- vim.keymap.set("n", "C-q", actions.smart_send_to_qflist + actions.open_qflist, {})
		vim.keymap.set("n", "<leader>F", customLiveGrep, {})
		-- list buffers
		vim.keymap.set("n", "<leader>b", builtin.buffers, {})
		-- Registers
		vim.keymap.set("n", "<leader>r", builtin.registers, {})
		-- vim.keymap.set("q", "<leader>q", builtin.
		vim.keymap.set("n", "<C-k>", "<C-p>")
	end
}
