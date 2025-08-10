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
		local lspconfig = require("lspconfig")
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
		-- Configure hover handler for better display
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
			vim.lsp.handlers.hover, {
				border = "rounded",
				max_width = 100,
				max_height = 30,
			}
		)
		-- Configure signature help handler
		vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
			vim.lsp.handlers.signature_help, {
				border = "rounded",
				max_width = 100,
			}
		)
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = bufnr,
			callback = function()
				local opts = {
					focusable = false,
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
					border = 'rounded',
					source = 'always',
					prefix = ' ',
					scope = 'cursor',
				}
				vim.diagnostic.open_float(nil, opts)
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
		require("mason-lspconfig").setup {
			--automatic_installation = false,
			automatic_enable = false,
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
			handlers = {
				-- Default handler
				function(server_name)
					lspconfig[server_name].setup {
						capabilities = capabilities,
					}
				end
			}
		}

		lspconfig.jsonls.setup {
			capabilities = capabilities,
			settings = {
				json = {
					schemas = require('schemastore').json.schemas(),
					validate = { enable = true },
				},
			},
		}
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			settings = {
				typescript = {
					inlayHints = {
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
			root_dir = function(fname)
				local util = require("lspconfig.util")
				return util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname) -- Simplified for all filetypes
			end,
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

		lspconfig.eslint.setup {
			capabilities = capabilities,
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
			root_dir = function(fname)
				local util = require("lspconfig.util")
				local eslint_config = util.root_pattern(
					'.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json',
					'.eslintrc.yaml', '.eslintrc.yml', 'eslint.config.js', 'eslint.config.mjs'
				)(fname)
				local package_json = util.root_pattern('package.json')(fname)
				local tsconfig = util.root_pattern('tsconfig.json')(fname)
				return eslint_config or package_json or tsconfig
			end,
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
			on_new_config = function(new_config, new_root_dir)
				new_config.settings = new_config.settings or {}
				local tsconfig_path = new_root_dir .. "/tsconfig.json"
				if vim.fn.filereadable(tsconfig_path) == 1 then
					new_config.settings.parserOptions = new_config.settings.parserOptions or {}
					new_config.settings.parserOptions.project = tsconfig_path
				end
			end,
			flags = {
				debounce_text_changes = 300,
			},
		}
		-- Lua LSP
		lspconfig.lua_ls.setup {
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
		}
		lspconfig.clangd.setup {
			capabilities = capabilities,
			filetypes = {
				"c", "cpp", "proto",
			},
		}
		local function vSplitAndExecute(callback)
			vim.cmd("vsplit")
			vim.cmd("wincmd l")
			if callback then callback() end
		end
		-- LSP keymap shortcuts
		-- Only remap keys after language server has attached to current buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(event)
				local opts = { buffer = event.buf }
				vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
				vim.keymap.set("n", "gd", function() vSplitAndExecute(vim.lsp.buf.definition) end, opts)
				vim.keymap.set("n", "gD", function() vSplitAndExecute(vim.lsp.buf.declaration) end, opts)
				vim.keymap.set("n", "gi", function() vSplitAndExecute(vim.lsp.buf.implementation) end, opts)
				vim.keymap.set("n", "go", function() vSplitAndExecute(vim.lsp.buf.type_definition) end, opts)
				vim.keymap.set("n", "gr", function() vSplitAndExecute(vim.lsp.buf.references) end, opts)
				vim.keymap.set("n", "gs", function() vSplitAndExecute(vim.lsp.buf.signature_help) end, opts)
				vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
				vim.keymap.set({ "n", "x" }, "fb", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
				vim.keymap.set("n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
				vim.keymap.set("n", "<leader>T", vim.lsp.buf.format)
			end,
		})
	end
}
