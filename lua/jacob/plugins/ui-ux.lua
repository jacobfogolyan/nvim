-- Professional UX/UI configuration for all-day coding comfort
return {
	-- Modern colorscheme with excellent contrast and reduced eye strain
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- Professional dark theme (latte, frappe, macchiato, mocha)
				background = {
					light = "latte",
					dark = "mocha",
				},
				transparent_background = false,
				show_end_of_buffer = false,
				term_colors = true,
				dim_inactive = {
					enabled = true, -- Dims inactive splits for better focus
					shade = "dark",
					percentage = 0.15,
				},
				no_italic = false,
				no_bold = false,
				no_underline = false,
				styles = {
					comments = { "italic" },
					conditionals = {},
					loops = {},
					functions = { "bold" },
					keywords = { "italic" },
					strings = {},
					variables = {},
					numbers = {},
					booleans = { "bold" },
					properties = {},
					types = { "italic" },
					operators = {},
				},
				color_overrides = {
					mocha = {
						base = "#1a1b26",     -- Slightly darker background for better contrast
						mantle = "#16161e",
						crust = "#13131a",
						surface0 = "#2a2b3d",
						surface1 = "#35364a",
						surface2 = "#404155",
						overlay0 = "#5a5b6e",
						overlay1 = "#6e6f85",
						overlay2 = "#82839c",
						
						-- Carefully chosen syntax colors for reduced eye strain
						text = "#c8d3f5",      -- Softer white
						subtext1 = "#b3b8d1",
						subtext0 = "#9da3c3",
						
						-- Semantic colors
						blue = "#82aaff",      -- Functions, keywords
						cyan = "#86e1fc",      -- Constants, types
						green = "#c3e88d",     -- Strings, success
						yellow = "#ffc777",    -- Warnings, classes
						peach = "#ff966c",     -- Numbers, important
						red = "#ff757f",       -- Errors, deletions
						mauve = "#c099ff",     -- Statements, special
						pink = "#fca7ea",      -- Builtins
						teal = "#4fd6be",      -- Hints, info
						lavender = "#b4befe",  -- Variables
						
						-- UI colors
						rosewater = "#ffc0cb",
						flamingo = "#ff9999",
						maroon = "#eba0ac",
						sky = "#89dceb",
						sapphire = "#74c7ec",
					},
				},
				custom_highlights = function(colors)
					return {
						-- Better cursor visibility
						CursorLine = { bg = colors.surface0 },
						CursorLineNr = { fg = colors.yellow, bg = colors.surface0, style = { "bold" } },
						
						-- Improved search highlighting
						Search = { bg = colors.yellow, fg = colors.base, style = { "bold" } },
						IncSearch = { bg = colors.peach, fg = colors.base, style = { "bold" } },
						
						-- Better diff colors
						DiffAdd = { bg = "#2d4a3d" },
						DiffChange = { bg = "#3d4a5d" },
						DiffDelete = { bg = "#4a2d3d" },
						DiffText = { bg = "#4a5d7d", style = { "bold" } },
						
						-- Floating windows with subtle borders
						NormalFloat = { bg = colors.mantle },
						FloatBorder = { fg = colors.overlay0, bg = colors.mantle },
						
						-- Better completion menu
						Pmenu = { bg = colors.surface0, fg = colors.text },
						PmenuSel = { bg = colors.surface2, fg = colors.yellow, style = { "bold" } },
						PmenuSbar = { bg = colors.surface1 },
						PmenuThumb = { bg = colors.overlay0 },
					}
				end,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = false,
					treesitter = true,
					notify = true,
					mini = {
						enabled = true,
						indentscope_color = "lavender",
					},
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "undercurl" },
							hints = { "undercurl" },
							warnings = { "undercurl" },
							information = { "undercurl" },
						},
						inlay_hints = {
							background = true,
						},
					},
				},
			})
			
			-- Set the colorscheme
			vim.cmd.colorscheme("catppuccin")
			
			-- Additional UI improvements
			vim.api.nvim_set_hl(0, "LineNr", { fg = "#5a5b6e" })
			vim.api.nvim_set_hl(0, "Comment", { fg = "#6e738d", italic = true })
			vim.api.nvim_set_hl(0, "VertSplit", { fg = "#2a2b3d", bg = "NONE" })
			vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#2a2b3d", bg = "NONE" })
		end,
	},

	-- Beautiful indent guides with scope highlighting
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
					tab_char = "│",
				},
				scope = {
					enabled = true,
					show_start = true,
					show_end = false,
					highlight = { "Function", "Label" },
					include = {
						node_type = {
							["*"] = { "*" },
						},
					},
				},
				exclude = {
					filetypes = {
						"help",
						"dashboard",
						"neo-tree",
						"Trouble",
						"lazy",
						"mason",
						"notify",
						"toggleterm",
						"lazyterm",
					},
				},
			})
		end,
	},

	-- Smooth scrolling for better visual continuity
	{
		"karb94/neoscroll.nvim",
		event = "VeryLazy",
		config = function()
			require("neoscroll").setup({
				mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
				hide_cursor = true,
				stop_eof = true,
				respect_scrolloff = false,
				cursor_scrolls_alone = true,
				easing_function = "sine",
				pre_hook = nil,
				post_hook = nil,
				performance_mode = false,
			})
		end,
	},

	-- Better UI for LSP progress and notifications
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		config = function()
			require("fidget").setup({
				progress = {
					poll_rate = 0,
					suppress_on_insert = false,
					ignore_done_already = false,
					ignore_empty_message = false,
					clear_on_detach = function(client_id)
						local client = vim.lsp.get_client_by_id(client_id)
						return client and client.name or nil
					end,
					notification_group = function(msg)
						return msg.lsp_client.name
					end,
					ignore = { "null-ls" },
					display = {
						render_limit = 16,
						done_ttl = 3,
						done_icon = "✔",
						done_style = "Constant",
						progress_ttl = math.huge,
						progress_icon = { pattern = "dots", period = 1 },
						progress_style = "WarningMsg",
						group_style = "Title",
						icon_style = "Question",
						priority = 30,
						skip_history = true,
						format_message = require("fidget.progress.display").default_format_message,
						format_annote = function(msg)
							return msg.title
						end,
						format_group_name = function(group)
							return tostring(group)
						end,
					},
				},
				notification = {
					poll_rate = 10,
					filter = vim.log.levels.INFO,
					history_size = 128,
					override_vim_notify = false,
					configs = { default = require("fidget.notification").default_config },
					redirect = function(msg, level, opts)
						if opts and opts.on_open then
							return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
						end
					end,
					view = {
						stack_upwards = true,
						icon_separator = " ",
						group_separator = "---",
						group_separator_hl = "Comment",
						render_message = function(msg, cnt)
							return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
						end,
					},
					window = {
						normal_hl = "Comment",
						winblend = 0,
						border = "none",
						zindex = 45,
						max_width = 0,
						max_height = 0,
						x_padding = 1,
						y_padding = 0,
						align = "bottom",
						relative = "editor",
					},
				},
			})
		end,
	},

	-- Beautiful notifications
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			local notify = require("notify")
			notify.setup({
				background_colour = "#1a1b26",
				fps = 60,
				icons = {
					DEBUG = "",
					ERROR = "",
					INFO = "",
					TRACE = "✎",
					WARN = "",
				},
				level = 2,
				minimum_width = 50,
				render = "compact",
				stages = "fade_in_slide_out",
				timeout = 3000,
				top_down = false,
			})
			vim.notify = notify
		end,
	},

	-- Improved command line UI
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				-- Hovers use Neovim's own float (lsp.lua) so the diagnostic float can
				-- stack under them; noice's hover window is invisible to that.
				hover = { enabled = false },
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
				opts = {},
				format = {
					cmdline = { pattern = "^:", icon = " ", lang = "vim" },
					search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
					search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
					filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
					lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
					help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
				},
			},
			messages = {
				enabled = true,
				view = "notify",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = "virtualtext",
			},
			popupmenu = {
				enabled = true,
				backend = "nui",
				kind_icons = {},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "written",
					},
					opts = { skip = true },
				},
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},

	-- Add a beautiful dashboard
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")
			
			-- Set header
			dashboard.section.header.val = {
				"                                                     ",
				"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
				"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
				"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
				"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
				"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
				"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
				"                                                     ",
			}
			
			-- Set menu
			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find file", ":lua require('fzf-lua').files()<CR>"),
				dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
				dashboard.button("r", "  Recently used files", ":lua require('fzf-lua').oldfiles()<CR>"),
				dashboard.button("t", "  Find text", ":lua require('fzf-lua').live_grep()<CR>"),
				dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
				dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
			}
			
			-- Set footer
			local function footer()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				return "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
			end
			
			dashboard.section.footer.val = footer()
			dashboard.section.footer.opts.hl = "Type"
			dashboard.section.header.opts.hl = "Include"
			dashboard.section.buttons.opts.hl = "Keyword"
			
			dashboard.opts.opts.noautocmd = true
			alpha.setup(dashboard.opts)
		end,
	},
}