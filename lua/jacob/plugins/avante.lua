return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	enabled = false,
	version = false,
	config = function()
		local cwd = vim.fn.getcwd()
		local is_clients_dir = string.find(cwd, "/clients") ~= nil

		local opts = {
			provider = is_clients_dir and "gemini" or "claude",

			-- Use a completely isolated function for file selection
			file_selector = {
				provider = function(params)
					-- Load Telescope modules but don't use the global setup
					local actions = require('telescope.actions')
					local action_state = require('telescope.actions.state')
					local pickers = require('telescope.pickers')
					local finders = require('telescope.finders')
					local conf = require('telescope.config').values

					-- Create a one-time picker that won't be affected by your global settings
					local picker = pickers.new({
						layout_strategy = "vertical",
						layout_config = {
							vertical = {
								preview_height = 0.5,
								results_height = 0.5,
							},
							height = 0.9,
							width = 0.9,
						}
					}, {
						prompt_title = params.title or "Select Files for Avante",
						finder = finders.new_oneshot_job({
							"find", ".", "-type", "f",
							"-not", "-path", "*/\\.git/*",
							"-not", "-path", "*/node_modules/*",
							"-not", "-path", "*/dist/*"
						}, {}),
						sorter = conf.generic_sorter({}),
						previewer = conf.file_previewer({}),
						attach_mappings = function(prompt_bufnr, map)
							-- Handle selection for avante
							actions.select_default:replace(function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								if selection and params.handler then
									params.handler({ selection.value })
								end
							end)
							return true
						end,
					})

					picker:find()
				end
			},

			-- Completely disable repo mapping filtering
			repo_map = {
				ignore_patterns = {},
				negate_patterns = { "src", "src/" }
			},

			behaviour = {
				use_cwd_as_project_root = true
			}
		}

		-- Provider configurations
		opts.gemini = {
			endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
			model = "gemini-1.5-flash-latest",
			timeout = 30000,
			temperature = 0,
			max_tokens = 4096,
		}

		opts.claude = {
			endpoint = "https://api.anthropic.com",
			model = "claude-3-5-sonnet-20241022",
			timeout = 30000,
			temperature = 0,
			max_tokens = 4096,
		}

		require("avante").setup(opts)

		-- Add a custom file add command that overrides avante's default
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "Avante",
			callback = function()
				vim.keymap.set("n", "@", function()
					-- Direct system command to find all files
					local picker = require('telescope.pickers').new({
						layout_strategy = "vertical",
						layout_config = {
							vertical = {
								preview_height = 0.5,
								results_height = 0.5,
							},
							height = 0.9,
							width = 0.9,
						}
					}, {
						prompt_title = "Add File to Avante",
						finder = require('telescope.finders').new_oneshot_job({
							"find", ".", "-type", "f",
							"-not", "-path", "*/\\.git/*",
							"-not", "-path", "*/node_modules/*"
						}),
						sorter = require('telescope.config').values.generic_sorter({}),
						previewer = require('telescope.config').values.file_previewer({}),
						attach_mappings = function(prompt_bufnr, map)
							require('telescope.actions').select_default:replace(function()
								local selection = require('telescope.actions.state').get_selected_entry()
								require('telescope.actions').close(prompt_bufnr)
								if selection then
									vim.cmd("AvanteAddFile " .. selection.value)
								end
							end)
							return true
						end,
					})

					picker:find()
				end, { buffer = 0, desc = "Add file with find" })
			end
		})
	end,
	dependencies = {
		-- Your existing dependencies
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"echasnovski/mini.pick",
		"nvim-telescope/telescope.nvim",
		"hrsh7th/nvim-cmp",
		"ibhagwan/fzf-lua",
		"nvim-tree/nvim-web-devicons",
		"zbirenbaum/copilot.lua",
		{
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					use_absolute_path = true,
				},
			},
		},
		{
			'MeanderingProgrammer/render-markdown.nvim',
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}

