return {
	"ibhagwan/fzf-lua",
	-- Replace Telescope with fzf-lua for massive performance gains
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		local fzf = require("fzf-lua")

		fzf.setup({
			-- Use native fzf binary for maximum speed
			winopts = {
				height = 0.85,
				width = 0.80,
				row = 0.35,
				col = 0.50,
				preview = {
					layout = "vertical",
					vertical = "down:45%",
				},
			},
			keymap = {
				builtin = {
					["<C-d>"] = "preview-page-down",
					["<C-u>"] = "preview-page-up",
				},
			},
			files = {
				prompt = "Files> ",
				multiprocess = true, -- Enable multiprocess for faster file searching
				git_icons = true,
				file_icons = true,
				color_icons = true,
				-- Use fd for ultra-fast file finding (install with: brew install fd)
				cmd = "fd --type f --hidden --follow --exclude .git",
			},
			grep = {
				prompt = "Grep> ",
				multiprocess = true,
				-- Use ripgrep for fast searching
				cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=512",
				rg_opts = "--hidden --glob '!.git' --glob '!node_modules'",
			},
			buffers = {
				prompt = "Buffers> ",
				file_icons = true,
				color_icons = true,
				sort_lastused = true,
			},
			lsp = {
				prompt_postfix = "> ",
				cwd_only = false,
				async_or_timeout = 5000,
				file_icons = true,
				git_icons = false,
			},
			git = {
				files = {
					prompt = "Git Files> ",
					multiprocess = true,
				},
			},
		})

		-- Keymaps - keeping the same as your Telescope mappings for seamless transition
		vim.keymap.set("n", "<leader>f", fzf.files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>F", fzf.live_grep, { desc = "Live grep" })
		vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Find buffers" })
		vim.keymap.set("n", "<leader>ps", function()
			fzf.grep({ search = vim.fn.input("Grep > ") })
		end, { desc = "Grep with input" })
		vim.keymap.set("n", "<leader>vh", fzf.help_tags, { desc = "Help tags" })
		vim.keymap.set("n", "<C-p>", fzf.git_files, { desc = "Git files" })
		vim.keymap.set("n", "<leader>of", fzf.oldfiles, { desc = "Old files" })
		vim.keymap.set("n", "<leader>r", fzf.registers, { desc = "Registers" }) -- Preserving original Telescope binding

		-- Additional ultra-fast search commands
		vim.keymap.set("n", "<leader>sw", fzf.grep_cword, { desc = "Search word under cursor" })
		vim.keymap.set("n", "<leader>sW", fzf.grep_cWORD, { desc = "Search WORD under cursor" })
		vim.keymap.set("n", "<leader>sl", fzf.blines, { desc = "Search in current buffer" })
		vim.keymap.set("n", "<leader>sr", fzf.resume, { desc = "Resume last search" })

		-- LSP integration
		vim.keymap.set("n", "<leader>lr", fzf.lsp_references, { desc = "LSP references" })
		vim.keymap.set("n", "<leader>ld", fzf.lsp_definitions, { desc = "LSP definitions" })
		vim.keymap.set("n", "<leader>li", fzf.lsp_implementations, { desc = "LSP implementations" })
		vim.keymap.set("n", "<leader>ls", fzf.lsp_document_symbols, { desc = "LSP document symbols" })
		vim.keymap.set("n", "<leader>lS", fzf.lsp_workspace_symbols, { desc = "LSP workspace symbols" })
		vim.keymap.set("n", "<leader>la", fzf.lsp_code_actions, { desc = "LSP code actions" })

		-- Git integration
		vim.keymap.set("n", "<leader>gc", fzf.git_commits, { desc = "Git commits" })
		vim.keymap.set("n", "<leader>gb", fzf.git_branches, { desc = "Git branches" })
		vim.keymap.set("n", "<leader>gS", fzf.git_status, { desc = "Git status (fzf)" }) -- Changed to gS to avoid conflict with Fugitive's gs
	end,
}

