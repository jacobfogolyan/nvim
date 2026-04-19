-- Enhanced status line with professional UX design
return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	priority = 999,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"tpope/vim-fugitive",
		"folke/trouble.nvim",
		"folke/lazy.nvim",
	},
	config = function()
		local status = require("lazy.status")
		
		-- Professional color palette
		local colors = {
			bg = "#1a1b26",
			fg = "#c8d3f5",
			yellow = "#ffc777",
			cyan = "#86e1fc",
			darkblue = "#2a2b3d",
			green = "#c3e88d",
			orange = "#ff966c",
			violet = "#c099ff",
			magenta = "#fca7ea",
			blue = "#82aaff",
			red = "#ff757f",
			grey = "#5a5b6e",
		}

		-- Custom theme for better visibility
		local custom_theme = {
			normal = {
				a = { fg = colors.bg, bg = colors.blue, gui = "bold" },
				b = { fg = colors.fg, bg = colors.darkblue },
				c = { fg = colors.grey, bg = colors.bg },
			},
			insert = {
				a = { fg = colors.bg, bg = colors.green, gui = "bold" },
				b = { fg = colors.fg, bg = colors.darkblue },
			},
			visual = {
				a = { fg = colors.bg, bg = colors.violet, gui = "bold" },
				b = { fg = colors.fg, bg = colors.darkblue },
			},
			replace = {
				a = { fg = colors.bg, bg = colors.red, gui = "bold" },
				b = { fg = colors.fg, bg = colors.darkblue },
			},
			command = {
				a = { fg = colors.bg, bg = colors.yellow, gui = "bold" },
				b = { fg = colors.fg, bg = colors.darkblue },
			},
			inactive = {
				a = { fg = colors.grey, bg = colors.bg },
				b = { fg = colors.grey, bg = colors.bg },
				c = { fg = colors.grey, bg = colors.bg },
			},
		}

		require("lualine").setup({
			options = {
				theme = custom_theme,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { statusline = { "dashboard", "alpha" } },
				always_divide_middle = true,
				globalstatus = false,
			},
			sections = {
				lualine_a = {
					{
						"mode",
						fmt = function(str)
							-- Show mode with icon
							local mode_icons = {
								NORMAL = " ",
								INSERT = " ",
								VISUAL = " ",
								["V-LINE"] = " ",
								["V-BLOCK"] = " ",
								REPLACE = " ",
								COMMAND = " ",
							}
							return (mode_icons[str] or " ") .. str
						end,
					},
				},
				lualine_b = {
					{
						"branch",
						icon = "",
						color = { fg = colors.violet, gui = "bold" },
					},
					{
						"diff",
						symbols = { added = " ", modified = " ", removed = " " },
						diff_color = {
							added = { fg = colors.green },
							modified = { fg = colors.orange },
							removed = { fg = colors.red },
						},
					},
				},
				lualine_c = {
					{
						"filename",
						file_status = true,
						path = 1, -- Relative path
						symbols = {
							modified = " ●",
							readonly = " ",
							unnamed = "[No Name]",
						},
						color = { fg = colors.fg, gui = "bold" },
					},
				},
				lualine_x = {
					{
						"diagnostics",
						sources = { "nvim_diagnostic" },
						symbols = { error = " ", warn = " ", info = " ", hint = " " },
						diagnostics_color = {
							error = { fg = colors.red },
							warn = { fg = colors.yellow },
							info = { fg = colors.cyan },
							hint = { fg = colors.blue },
						},
						always_visible = false,
					},
					{
						function()
							local msg = "No Active Lsp"
							local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
							local clients = vim.lsp.get_clients()
							if next(clients) == nil then
								return msg
							end
							local client_names = {}
							for _, client in ipairs(clients) do
								local filetypes = client.config.filetypes
								if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
									table.insert(client_names, client.name)
								end
							end
							if #client_names > 0 then
								return table.concat(client_names, ", ")
							end
							return msg
						end,
						icon = " ",
						color = { fg = colors.cyan },
					},
					{
						status.updates,
						cond = status.has_updates,
						color = { fg = colors.orange },
					},
					{ "encoding", color = { fg = colors.green } },
					{ "fileformat", color = { fg = colors.green } },
					{
						"filetype",
						colored = true,
						icon_only = false,
					},
				},
				lualine_y = {
					{
						"progress",
						color = { fg = colors.fg, gui = "bold" },
					},
				},
				lualine_z = {
					{
						"location",
						fmt = function()
							local line = vim.fn.line(".")
							local col = vim.fn.col(".")
							return string.format("%3d:%-2d", line, col)
						end,
						color = { fg = colors.bg, bg = colors.cyan, gui = "bold" },
					},
				},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						"filename",
						file_status = true,
						path = 1,
						symbols = {
							modified = " ●",
							readonly = " ",
							unnamed = "[No Name]",
						},
						color = { fg = colors.grey },
					},
				},
				lualine_x = { 
					{ "location", color = { fg = colors.grey } }
				},
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = { "fugitive", "fzf", "quickfix", "trouble" },
		})
	end,
}