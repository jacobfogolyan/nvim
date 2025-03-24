return {
	"mhartington/formatter.nvim",
	config = function()
		-- Utilities for creating configurations
		local function format_prettier()
			return {
				exe = "prettier", -- Use globally installed prettier
				args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
				stdin = true
			}
		end
		-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
		require("formatter").setup {
			-- Enable or disable logging
			logging = true,
			-- Set the log level
			log_level = vim.log.levels.WARN,
			-- All formatter configurations are opt-in
			filetype = {
				typescriptreact = { format_prettier },
				typescript = { format_prettier },
				javascript = { format_prettier },
				javascriptreact = { format_prettier },
				json = { format_prettier },
				vue = { format_prettier },
				css = { format_prettier },
				scss = { format_prettier },
				yaml = {
					function()
						return {
							exe = "npx",
							args = { "prettier", "--parser", "yaml", "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
							stdin = true
						}
					end
				},
				mjs = { format_prettier },
				lua = {
					-- luafmt
					function()
						return {
							exe = "stylua",
							args = { "-" }, -- Stylua reads from stdin
							stdin = true
						}
					end
				},
				cpp = {
					-- clang-format
					function()
						return {
							exe = "clang-format",
							args = { "--assume-filename", vim.api.nvim_buf_get_name(0) },
							stdin = true
						}
					end
				},
				-- Use the special "*" filetype for defining formatter configurations on
				-- any filetype
				["*"] = {
					-- "formatter.filetypes.any" defines default configurations for any
					-- filetype
					require("formatter.filetypes.any").remove_trailing_whitespace
				}
			}
		}
		local Jacob_Formatter = vim.api.nvim_create_augroup("Jacob_Formatter", {})
		local autocmd = vim.api.nvim_create_autocmd

		autocmd("BufWritePost", {
			group = Jacob_Formatter,
			pattern = { "*.vue", "*.js", "*.jsx", "*.ts", "*.tsx", "*.py", "*.html", "*.css", "*.scss", "*.mjs", "*.yml", "*.json", "*.cpp" },
			callback = function()
				vim.cmd("FormatWrite")
			end
		})

		vim.api.nvim_create_user_command('W', 'noautocmd w', {})
	end
}
