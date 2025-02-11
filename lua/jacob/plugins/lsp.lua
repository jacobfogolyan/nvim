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

		lspconfig.volar.setup {}

		local vue_typescript_plugin = require('mason-registry')
			.get_package('vue-language-server')
			:get_install_path()
			.. '/node_modules/@vue/language-server'
			.. '/node_modules/@vue/typescript-plugin'

		lspconfig.ts_ls.setup {
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
			},
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

		-- start_path will be the buffers current path
		--		local function find_closest_eslint_config_dir()
		--			local root_files = {
		--				'.eslintrc',
		--				'.eslintrc.js',
		--				'.eslintrc.cjs',
		--				'.eslintrc.yaml',
		--				'.eslintrc.yml',
		--				'.eslintrc.json',
		--				'eslint.config.js',
		--				'eslint.config.mjs',
		--				'eslint.config.cjs',
		--				'eslint.config.ts',
		--				'eslint.config.mts',
		--				'eslint.config.cts',
		--			}
		--
		--			local search_path = vim.api.nvim_buf_get_name(0);
		--			while search_path do
		--				local has_package_json = util.path.exists(util.path.join(search_path, 'package.json'))
		--				local has_eslint_config = false
		--
		--				for _, root_file in ipairs(root_files) do
		--					if util.path.exists(util.path.join(search_path, root_file)) then
		--						has_eslint_config = true
		--						break
		--					end
		--				end
		--
		--				if has_package_json and has_eslint_config then
		--					return search_path
		--				end
		--
		--				search_path = util.path.dirname(search_path)
		--				if search_path == util.path.dirname(search_path) then
		--					return nil
		--				end
		--			end
		--		end
		--
		--		local custom_root_dir = function(fname)
		--			return find_closest_eslint_config_dir() or util.find_git_ancestor(fname)
		--		end

		lspconfig.eslint.setup {
			capabilities = capabilities,
			-- 			root_dir = custom_root_dir,
			-- 			settings = {
			-- 				workingDirectory = { mode = 'location' }
			-- 			}
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
