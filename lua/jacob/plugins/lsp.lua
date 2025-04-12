return {
	"neovim/nvim-lspconfig",

	event = {
		"BufReadPre",
		"BufNewFile",
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
		} -- Setup fidget for LSP progress information

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
			library = {}, ---@type lazydev.Library.spec[]
			integrations = {
				lspconfig = true,
				cmp = true
			},
			debug = false
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
				"ts_ls",
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
				"arduino_language_server",
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

		lspconfig.volar.setup {
			capabilities = capabilities,
			filetypes = { 'vue', 'typescript', 'javascript' },
			-- Only activate in Nuxt projects
			root_dir = lspconfig.util.root_pattern('nuxt.config.ts', 'nuxt.config.js'),
			init_options = {
				typescript = {
					tsdk = '/Users/jacob/.local/share/nvim/mason/packages/typescript-language-server/node_modules/typescript/lib'
				},
				vue = {
					hybridMode = false, -- Disable hybrid mode to let Volar handle TS
				},
				languageFeatures = {
					implementation = true,
					references = true,
					definition = true,
					typeDefinition = true,
					callHierarchy = true,
					hover = true,
					rename = true,
					signatureHelp = true,
					codeAction = true,
					workspaceSymbol = true,
					diagnostics = true,
					-- Nuxt-specific completion features
					completion = {
						defaultTagNameCase = 'both',
						defaultAttrNameCase = 'kebabCase',
						autoImport = true,
						-- Support Nuxt components auto-import
						path = true
					},
				}
			}
		}

		lspconfig.ts_ls.setup {
			capabilities = capabilities,
			filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' },
			-- Exclude Vue files completely from ts_ls
			root_dir = function(fname)
				if string.match(fname, '%.vue$') then
					return nil
				end
				return lspconfig.util.root_pattern('nuxt.config.ts', 'nuxt.config.js', 'package.json', 'tsconfig.json',
					'jsconfig.json', '.git')(fname)
			end
		}

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
			filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
			root_dir = function(fname)
				local util = require("lspconfig.util")

				-- First look for eslint config files
				local eslint_config = util.root_pattern(
					'.eslintrc',
					'.eslintrc.js',
					'.eslintrc.json',
					'.eslintrc.yaml',
					'.eslintrc.yml',
					'eslint.config.js',
					'eslint.config.mjs'
				)(fname)

				-- Then look for package.json and tsconfig.json as fallbacks
				local package_json = util.root_pattern('package.json')(fname)
				local tsconfig = util.root_pattern('tsconfig.json')(fname)

				-- Return the first valid root directory found
				return eslint_config or package_json or tsconfig
			end,
			settings = {
				-- This is critical for monorepos and projects with workspace configurations
				workingDirectory = { mode = "location" },
				codeAction = {
					disableRuleComment = {
						enable = true,
						location = "separateLine"
					},
					showDocumentation = {
						enable = true
					}
				},
				experimental = {
					useFlatConfig = false -- Set to false since you're using module.exports format
				},
				format = { enable = true },
				nodePath = "", -- Set this to your project's node_modules path if needed
				run = "onType",
				validate = "on",
			},
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					command = "EslintFixAll",
				})
				-- Debug output
			end,
			on_new_config = function(new_config, new_root_dir)
				-- Support for monorepo structure
				new_config.settings = new_config.settings or {}
			end,
			flags = {
				debounce_text_changes = 150,
			}
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

		lspconfig.clangd.setup {
			capabilities = capabilities,
			filetypes = {
				"c", "cpp", "proto",
			},
		}

		lspconfig.arduino_language_server.setup {
			cmd = {
				"arduino-language-server",
				"-clangd", "/usr/bin/clangd",
				"-cli", "/opt/homebrew/bin/arduino-cli",
				"-cli-config", "/Users/jacob/Library/Arduino15/arduino-cli.yaml",
				"-fqbn", "arduino:esp32:nano_nora"
			},
			filetypes = { "cpp", "arduino" }, -- Filetypes to attach to
			root_dir = lspconfig.util.root_pattern("*.ino", "*.cpp", ".git"),
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
				-- vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
				vim.keymap.set("n", "gd", function() vSplitAndExecute(vim.lsp.buf.definition) end, opts)
				vim.keymap.set("n", "gD", function() vSplitAndExecute(vim.lsp.buf.declaration) end, opts)
				vim.keymap.set("n", "gi", function() vSplitAndExecute(vim.lsp.buf.implementation) end, opts)
				vim.keymap.set("n", "go", function() vSplitAndExecute(vim.lsp.buf.type_definition) end, opts)
				vim.keymap.set("n", "gr", function() vSplitAndExecute(vim.lsp.buf.references) end, opts)
				vim.keymap.set("n", "gs", function() vSplitAndExecute(vim.lsp.buf.signature_help) end, opts)
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
