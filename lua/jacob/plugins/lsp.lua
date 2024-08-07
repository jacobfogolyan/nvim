return {
	"neovim/nvim-lspconfig",

	event = {
		"InsertEnter",
		"CmdlineEnter",
	},

	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
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

		require("mason").setup {
			max_concurrent_installers = 4,
			ui = {
				check_outdated_packages_on_open = true,
				border = "double"
			}
		}

		require("lazydev").setup {
			lspconfig = true,
		}

		require("mason-lspconfig").setup {
			automatic_installation = false,
			-- These are the language servers that we want automatically installed.
			ensure_installed = {
				"gopls",
				"golangci_lint_ls",
				"rust_analyzer",
				"clangd",
				"elixirls",
				"tsserver",
				"eslint",
				"kotlin_language_server",
				"yamlls",
				"lua_ls",
				"pyright",
				"ansiblels",
				"bashls",
				"crystalline",
				"dockerls",
				"cmake",
				"cssls",
				"taplo",
				"volar",
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

		lspconfig.volar.setup {}

		local vue_typescript_plugin = require('mason-registry')
			.get_package('vue-language-server')
			:get_install_path()
			.. '/node_modules/@vue/language-server'
			.. '/node_modules/@vue/typescript-plugin'

		lspconfig.tsserver.setup {
			init_options = {
				plugins = {
					{
						--revisit
						name = "@vue/typescript-plugin",
						location = vue_typescript_plugin,
						languages = { "javascript", "typescript", "vue" },
					}
				}
			},
			filetypes = {
				"javascript",
				"typescript",
				"vue",
				"javascriptreact",
				"typescriptreact"
			}
		}
		-- Customize hover window
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
			vim.lsp.handlers.hover, {
				border = "double",
				max_width = 80, -- Adjust the maximum width according to your needs
				max_height = 20, -- Adjust the maximum height according to your needs
			}
		)

		-- Go LSP
		lspconfig.gopls.setup {
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
						unusedwrite = true,
						fieldalignment = true,
					},
					hints = {
						parameterNames = true,
					},
					staticcheck = true,
					gofumpt = true,
					completeUnimported = true,
					usePlaceholders = true,
				}
			}
		}

		lspconfig.eslint.setup {
			capabilities = capabilities,
		}
		-- Clang LSP
		lspconfig.clangd.setup {
			filetypes = {
				"c", "cpp", "proto",
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

		-- Gdscript LSP
		lspconfig.gdscript.setup {
			capabilities = capabilities,
			cmd = {
				"ncat", "localhost", "6008",
			}
		}

		-- LSP keymap shortcuts
		-- Only remap keys after language server has attached to current buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(event)
				local opts = { buffer = event.buf }

				vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
				vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
				vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
				vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
				vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
				vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
				vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
				vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
				vim.keymap.set({ "n", "x" }, "fb", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)

				-- Code action picker
				vim.keymap.set("n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

				-- LSP reformat current buffer
				vim.keymap.set("n", "<leader>T", vim.lsp.buf.format)
			end,
		})

		-- LSP auto-formatting for Go.
		-- This will automatically sort imports.
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.go",
			callback = function()
				local params = vim.lsp.util.make_range_params()
				params.context = { only = { "source.organizeImports" } }
				-- buf_request_sync defaults to a 1000ms timeout. Depending on your
				-- machine and codebase, you may want longer. Add an additional
				-- argument after params if you find that you have to write the file
				-- twice for changes to be saved.
				-- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
				local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
				for cid, res in pairs(result or {}) do
					for _, r in pairs(res.result or {}) do
						if r.edit then
							local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
							vim.lsp.util.apply_workspace_edit(r.edit, enc)
						end
					end
				end
				vim.lsp.buf.format({ async = false })
			end
		})
	end
}
