return {
	"olimorris/codecompanion.nvim",
	enabled = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	schema = {
		model = {
			-- Always show at top of chat buffer
			order = 1,
			default = "claude-3.7-sonnet",
			choices = {
				"claude-3.5-sonnet",
				"claude-3.7-sonnet",
				"claude-3.7-sonnet-thought"
			}
		},
	},
	config = function()
		require("codecompanion").setup {
			adapters = {
				filesystem = {
					enabled = true,
				},
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								-- Always show at top of chat buffer
								order = 1,
								default = "claude-3.7-sonnet",
								choices = {
									"claude-3.5-sonnet",
									"claude-3.7-sonnet",
									"claude-3.7-sonnet-thought"
								}
							},
							-- num_ctx = {
							--     default = 50000
							-- }
						}
					})
				end
			},
		}
		vim.keymap.set("n", "<leader>cc", ":CodeCompanionChat Toggle<cr>", { silent = true, noremap = true })
	end
}
