return {
	"mhartington/formatter.nvim",
	config = function()
		local function format_prettier()
			return {
				exe = "npx",
				args = { "prettier", "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
				stdin = true
			}
		end

		local function format_eslint()
			return {
				exe = "npx",
				args = { "eslint", "--fix", vim.api.nvim_buf_get_name(0) },
				stdin = false
			}
		end

		-- Path-based formatter selection
		local function get_formatter()
			local file_path = vim.fn.expand("%:p")

			-- Define your parent folders
			local prettier_parent = "/Users/jacob/Development/vsf/clients"
			local eslint_parent = "/Users/jacob/Development/personal"

			-- Check which parent folder contains this file
			if string.match(file_path, prettier_parent) then
				return format_prettier()
			elseif string.match(file_path, eslint_parent) then
				return format_eslint()
			else
				-- Default formatter for files outside these folders
				return format_prettier() -- or whatever default you prefer
			end
		end
		-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
		require("formatter").setup {
			-- Enable or disable logging
			logging = true,
			-- Set the log level
			log_level = vim.log.levels.WARN,
			-- All formatter configurations are opt-in
			filetype = {
				typescriptreact = { get_formatter },
				typescript = { get_formatter },
				javascript = { get_formatter },
				javascriptreact = { get_formatter },
				json = { get_formatter },
				vue = { get_formatter },
				css = { get_formatter },
				scss = { get_formatter },
				yaml = {
					function()
						return {
							exe = "npx",
							args = { "prettier", "--parser", "yaml", "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
							stdin = true
						}
					end
				},
				mjs = { get_formatter },
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
