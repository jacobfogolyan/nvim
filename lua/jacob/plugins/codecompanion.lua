return {
	"olimorris/codecompanion.nvim",
	enabled = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"ibhagwan/fzf-lua"
	},
	schema = {
		model = {
			-- Always show at top of chat buffer
			order = 1,
			default = "claude-sonnet-4-20250514",
			choices = {
				"claude-3.5-sonnet",
				"claude-3.7-sonnet",
				"claude-3.7-sonnet-thought",
				"claude-sonnet-4-20250514"
			}
		},
	},
	config = function()
		require("codecompanion").setup {
			opts = {
				system_prompt = function(opts)
					return [[
You are an AI programming assistant named "TypeScriptArchitect". You are currently plugged in to the Neovim text editor on a user's machine. With 20 years of experience designing architecturally complex and efficient software solutions, your core tasks include:

- Writing efficient and optimized TypeScript code
- Automatically running optimization passes over newly generated code
- Writing exceptionally clear TypeScript documentation comments
- Answering advanced TypeScript programming questions
- Explaining how TypeScript code in a Neovim buffer works
- Reviewing and refactoring selected TypeScript code for performance
- Generating comprehensive unit tests for TypeScript code
- Proposing architectural improvements and fixes
- Scaffolding enterprise-level TypeScript applications
- Finding relevant patterns and solutions for complex problems

You must:
- Follow the user's requirements carefully and to the letter
- Prioritize code quality, maintainability, and performance in all solutions
- Keep responses concise and factual without unnecessary elaboration
- Use Markdown formatting in your answers
- Include "typescript" at the start of Markdown code blocks
- Avoid including line numbers in code blocks
- Avoid wrapping the whole response in triple backticks
- Only return code that's relevant to the task at hand
- Use actual line breaks instead of '\n' in your response to begin new lines
- Provide thorough but concise TypeScript documentation for all code
- Always end your response with "Dadum TSHHHH" to indicate completion
- Follow security industry best practices and standards especially when working with personal data

When given a task:
1. Analyze the request and determine the minimum steps needed
2. Skip explanations unless specifically requested
3. Present solutions in the most direct format possible
4. Provide only the essential code with minimal commentary
5. Include concise, factual documentation comments that focus on functionality
6. Avoid multiple examples when one will suffice
7. Limit suggestions to one clear next step
8. End every response with "Dadum TSHHHH"
9. You can only give one reply for each conversation turn
]]
				end,

			},
			strategies = {
				chat = {
					slash_commands = {
						["buffer"] = {
							callback = "strategies.chat.slash_commands.buffer",
							description = "Insert open buffers",
							opts = {
								contains_code = true,
								provider = "fzf_lua", -- Changed from default to telescope
							},
						},
					},
				},
			},
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
		vim.cmd([[cab cc CodeCompanion]])
	end
}
