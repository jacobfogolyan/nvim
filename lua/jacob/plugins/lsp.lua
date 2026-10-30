return {
	"neovim/nvim-lspconfig",
	-- Lazy load LSP only when needed
	event = { "BufReadPost", "BufNewFile" },
	cmd = { "LspInfo", "LspInstall", "LspUninstall" },
	dependencies = {
		"mason-org/mason.nvim",
		"mason-org/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"folke/lazydev.nvim",
		"j-hui/fidget.nvim",
	},
	config = function()
		local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
		-- `require("lspconfig")` is deprecated (removed in nvim-lspconfig v3).
		-- Server configs now come from nvim-lspconfig's `lsp/*.lua` specs and are
		-- customised via `vim.lsp.config()` / activated via `vim.lsp.enable()`.
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			has_cmp and cmp_nvim_lsp.default_capabilities() or {}
		)
		vim.diagnostic.config({
			virtual_text = {
				source = "if_many",
				prefix = "●",
				format = function(diagnostic)
					local max_width = 80
					local message = diagnostic.message
					if string.len(message) > max_width then
						return string.sub(message, 1, max_width) .. "..."
					end
					return message
				end,
			},
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "if_many",
				header = "",
				prefix = "",
				max_width = math.min(vim.o.columns - 4, 120),
				max_height = math.min(vim.o.lines - 4, 30),
				wrap = true,
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
		})
		-- `vim.lsp.with()` is deprecated; hover/signature_help take these options
		-- directly at the call site instead (see the LspAttach keymaps below).
		-- Hover prefers below the line; the CursorHold diagnostic stacks under it.
		local hover_opts = { border = "rounded", max_width = 100, max_height = 30, anchor_bias = "below" }
		local signature_opts = { border = "rounded", max_width = 100 }

		-- With a hover open, move the diagnostic float to sit just under it (or just
		-- above it when the hover had to open above the cursor). Without a hover the
		-- diagnostic float keeps its normal spot.
		local function stackDiagnosticOnHover(hover)
			local diag = vim.b.diagnostic_float
			if not (diag and hover and diag ~= hover and vim.api.nvim_win_is_valid(diag) and vim.api.nvim_win_is_valid(hover)) then
				return
			end
			local hover_cfg = vim.api.nvim_win_get_config(hover)
			local below = hover_cfg.anchor:sub(1, 1) == "N"
			vim.api.nvim_win_set_config(diag, {
				relative = "win",
				win = hover,
				anchor = below and "NW" or "SW",
				row = below and hover_cfg.height + 1 or -1,
				col = -1,
			})
		end

		-- Every hover (K, <leader>K, the merged-type popup) opens through here.
		local open_floating_preview = vim.lsp.util.open_floating_preview
		vim.lsp.util.open_floating_preview = function(...)
			local buf, win = open_floating_preview(...)
			stackDiagnosticOnHover(win)
			return buf, win
		end

		vim.api.nvim_create_autocmd("CursorHold", {
			callback = function()
				local open = vim.b.diagnostic_float
				if open and vim.api.nvim_win_is_valid(open) then
					return
				end
				local opts = {
					focusable = false,
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
					border = 'rounded',
					-- `source = 'always'` was deprecated in favour of a boolean.
					source = true,
					prefix = ' ',
					scope = 'cursor',
				}
				-- open_floating_preview allows one float per buffer and closes the last
				-- one. Hide the hover from it so the hover survives, and keep the
				-- diagnostic float out of that slot so a later hover doesn't close it.
				local hover = vim.b.lsp_floating_preview
				vim.b.lsp_floating_preview = nil
				local _, win = vim.diagnostic.open_float(nil, opts)
				vim.b.lsp_floating_preview = hover
				vim.b.diagnostic_float = win
				stackDiagnosticOnHover(hover)
			end
		})
		-- Increase updatetime for better performance
		vim.opt.updatetime = 750
		require("mason").setup {
			max_concurrent_installers = 4,
			ui = {
				check_outdated_packages_on_open = true,
				border = "double"
			}
		}
		-- Setup fidget for LSP progress information
		require("fidget").setup {
			progress = {
				display = {
					done_ttl = 3,
				},
			},
			notification = {
				window = {
					winblend = 0,
				},
			},
		}
		require("lazydev").setup {
			lspconfig = true,
			enabled = true,
			runtime = vim.env.VIMRUNTIME --[[@as string]],
			library = {},
			integrations = {
				lspconfig = true,
				cmp = true
			},
			debug = false
		}
		-- Applied to every server, replacing the old mason-lspconfig `handlers`
		-- default handler (removed in mason-lspconfig v2).
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		require("mason-lspconfig").setup {
			--automatic_installation = false,
			-- v2 replacement for the removed `handlers` option: every installed
			-- server is enabled automatically, picking up the `*` config above.
			automatic_enable = true,
			-- These are the language servers that we want automatically installed.
			ensure_installed = {
				"clangd",
				"elixirls",
				"ts_ls",
				"eslint",
				"yamlls",
				"lua_ls",
				"jsonls",
				"pyright",
				"bashls",
				"crystalline",
				"dockerls",
				"cmake",
				"cssls",
				"taplo",
				"prismals",
			},
		}

		vim.lsp.config("jsonls", {
			settings = {
				json = {
					schemas = require('schemastore').json.schemas(),
					validate = { enable = true },
				},
			},
		})
		vim.lsp.config("ts_ls", {
			settings = {
				typescript = {
					inlayHints = {
						enumMemberValues = {
							enabled = true,
						},
						includeInlayParameterNameHints = 'all',
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
					tsdk = 'node_modules/typescript/lib', -- Use project-local TypeScript
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = 'all',
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }, -- Include vue
			-- List order is priority, matching the old `util.root_pattern` call.
			root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
			init_options = {
				plugins = {
					{
						name = '@vue/typescript-plugin',
						location = vim.fn.stdpath 'data' ..
							'/mason/packages/vue-language-server/node_modules/@vue/language-server',
						languages = { 'vue' },
					},
				},
			},
			flags = {
				debounce_text_changes = 300,
			},
		})

		vim.lsp.config("eslint", {
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
			-- List order is priority: eslint configs first, then package.json,
			-- then tsconfig.json — matching the old root_dir fallback chain.
			root_markers = {
				'.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json',
				'.eslintrc.yaml', '.eslintrc.yml', 'eslint.config.js', 'eslint.config.mjs',
				'package.json', 'tsconfig.json',
			},
			settings = {
				workingDirectory = { mode = "location" },
				codeAction = {
					disableRuleComment = { enable = true, location = "separateLine" },
					showDocumentation = { enable = true }
				},
				experimental = {
					useFlatConfig = false
				},
				format = { enable = true },
				nodePath = "",
				run = "onSave",
				validate = "on",
				parserOptions = {
					project = { "./tsconfig.json", "**/tsconfig.json" },
				}
			},
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					command = "EslintFixAll",
				})
			end,
			-- `on_new_config` was an nvim-lspconfig hook; `before_init` is the
			-- vim.lsp equivalent and still sees the resolved root_dir.
			before_init = function(_, config)
				if not config.root_dir then
					return
				end
				local tsconfig_path = config.root_dir .. "/tsconfig.json"
				if vim.fn.filereadable(tsconfig_path) == 1 then
					config.settings = config.settings or {}
					config.settings.parserOptions = config.settings.parserOptions or {}
					config.settings.parserOptions.project = tsconfig_path
				end
			end,
			flags = {
				debounce_text_changes = 300,
			},
		})
		-- Lua LSP
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					format = {
						enable = true,
					},
					defaultConfig = {
						indent_style = "space",
						indent_size = "2",
					},
					diagnostics = {
						globals = { "vim", "it", "describe", "before_each", "after_each" }
					}
				}
			}
		})
		vim.lsp.config("clangd", {
			filetypes = {
				"c", "cpp", "proto",
			},
		})
		-- Ask the LSP first and split only once it returns locations (an empty
		-- result just notifies). Several results also open the quickfix list.
		local function vSplitAndExecute(lsp_fn)
			lsp_fn({
				on_list = function(list)
					vim.fn.setqflist({}, " ", list)
					vim.cmd("vsplit")
					vim.cmd("wincmd l")
					vim.cmd("cfirst")
					if #list.items > 1 then
						vim.cmd("botright copen")
						vim.cmd("wincmd p")
					end
				end,
			})
		end
		-- K in TypeScript: show the fully merged members of the type under the cursor
		-- (scripts/ts-members.cjs). Falls back to the normal hover when it has nothing.
		-- The script runs as one long-lived server so TypeScript and its lib files
		-- stay loaded: ~250ms for the first request, ~15ms after that.
		local ts_members_script = vim.fn.stdpath("config") .. "/scripts/ts-members.cjs"
		local members_server, members_waiting, members_buf = nil, {}, ""
		local function membersRequest(req, on_reply)
			if not members_server then
				members_server = vim.system({ "node", ts_members_script, "--serve" }, {
					stdin = true,
					stdout = function(_, data)
						members_buf = members_buf .. (data or "")
						for line in members_buf:gmatch("([^\n]*)\n") do
							local cb = table.remove(members_waiting, 1)
							if cb then vim.schedule(function() cb(vim.json.decode(line).out) end) end
						end
						members_buf = members_buf:match("[^\n]*$")
					end,
				}, function()
					-- Server died: answer anyone still waiting, restart on the next K.
					local waiting = members_waiting
					members_server, members_waiting, members_buf = nil, {}, ""
					for _, cb in ipairs(waiting) do vim.schedule(function() cb(vim.NIL) end) end
				end)
			end
			table.insert(members_waiting, on_reply)
			members_server:write(vim.json.encode(req) .. "\n")
		end
		local function tsMembersHover()
			local cursor = vim.api.nvim_win_get_cursor(0)
			membersRequest({
				file = vim.api.nvim_buf_get_name(0),
				line = cursor[1] - 1,
				col = cursor[2],
				text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"),
			}, function(out)
				if type(out) ~= "string" then
					return vim.lsp.buf.hover(hover_opts)
				end
				vim.lsp.util.open_floating_preview(vim.split(out, "\n"), "typescript", hover_opts)
			end)
		end
		-- LSP keymap shortcuts
		-- Only remap keys after language server has attached to current buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(event)
				local opts = { buffer = event.buf }
				local ft = vim.bo[event.buf].filetype
				if ft == "typescript" or ft == "typescriptreact" then
					vim.keymap.set("n", "K", tsMembersHover, opts)
					-- Warm the server now so the first K is fast too.
					membersRequest({ file = vim.api.nvim_buf_get_name(event.buf), line = 0, col = 0, text = "" }, function() end)
				else
					vim.keymap.set("n", "K", function() vim.lsp.buf.hover(hover_opts) end, opts)
				end
				vim.keymap.set("n", "<leader>K", function() vim.lsp.buf.hover(hover_opts) end, opts)
				vim.keymap.set("n", "gd", function() vSplitAndExecute(vim.lsp.buf.definition) end, opts)
				vim.keymap.set("n", "gD", function() vSplitAndExecute(vim.lsp.buf.declaration) end, opts)
				vim.keymap.set("n", "gi", function() vSplitAndExecute(vim.lsp.buf.implementation) end, opts)
				vim.keymap.set("n", "go", function() vSplitAndExecute(vim.lsp.buf.type_definition) end, opts)
				vim.keymap.set("n", "gr", function()
					vSplitAndExecute(function(o) vim.lsp.buf.references(nil, o) end)
				end, opts)
				vim.keymap.set("n", "gs", function() vim.lsp.buf.signature_help(signature_opts) end, opts)
				vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
				vim.keymap.set({ "n", "x" }, "fb", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
				vim.keymap.set("n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
				vim.keymap.set("n", "<leader>T", vim.lsp.buf.format)
			end,
		})
	end
}
