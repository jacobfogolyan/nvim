-- nvim-treesitter `main` branch (rewrite). Requires Neovim 0.12+.
-- NOTE: the `main` branch does NOT support lazy-loading, hence `lazy = false`.
-- Migrated from the old `master` API (`require("nvim-treesitter.configs").setup`),
-- which was removed upstream. Keybindings gnn/grn/grc/grm are preserved.
return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local ts = require("nvim-treesitter")

		ts.setup({})

		local ensure_installed = {
			"bash",
			"comment",
			"typescript",
			"make",
			"cpp",
			"dockerfile",
			"vim",
			"vimdoc",
			"query",
			"toml",
			"yaml",
			"json",
			"gitcommit",
			"gitignore",
			"fish",
			"css",
			"lua",
			"vue",
			"javascript",
			"tsx",
			"prisma",
			"graphql",
		}

		-- Asynchronous; a no-op for parsers that are already installed.
		ts.install(ensure_installed)

		local max_filesize = 100 * 1024 -- 100 KB
		-- Treesitter indent is still experimental upstream; these were disabled before.
		local indent_disabled = { yaml = true, python = true }

		--- Incremental selection. The `main` branch dropped this module, so it is
		--- reimplemented here to keep the original keymaps working.
		local sel = {}

		local function set_selection(buf, node)
			local srow, scol, erow, ecol = node:range()
			vim.fn.setpos("'<", { buf, srow + 1, scol + 1, 0 })
			vim.fn.setpos("'>", { buf, erow + 1, ecol, 0 })
			vim.cmd("normal! gv")
		end

		local function init_selection()
			local buf = vim.api.nvim_get_current_buf()
			local node = vim.treesitter.get_node()
			if not node then
				return
			end
			sel[buf] = { node }
			set_selection(buf, node)
		end

		--- Walk up until the range actually grows, so repeated presses always expand.
		local function grow(node, scope)
			local srow, scol, erow, ecol = node:range()
			local parent = node:parent()
			while parent do
				local psrow, pscol, perow, pecol = parent:range()
				local bigger = psrow ~= srow or pscol ~= scol or perow ~= erow or pecol ~= ecol
				-- "scope" expands further: keep climbing until the line span grows too.
				if bigger and (not scope or psrow < srow or perow > erow) then
					return parent
				end
				parent = parent:parent()
			end
			return nil
		end

		local function expand(scope)
			return function()
				local buf = vim.api.nvim_get_current_buf()
				local stack = sel[buf]
				if not stack or #stack == 0 then
					init_selection()
					return
				end
				local parent = grow(stack[#stack], scope)
				if not parent then
					set_selection(buf, stack[#stack])
					return
				end
				table.insert(stack, parent)
				set_selection(buf, parent)
			end
		end

		local function shrink()
			local buf = vim.api.nvim_get_current_buf()
			local stack = sel[buf]
			if not stack or #stack < 2 then
				return
			end
			table.remove(stack)
			set_selection(buf, stack[#stack])
		end

		vim.api.nvim_create_autocmd("BufDelete", {
			callback = function(args)
				sel[args.buf] = nil
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("JacobTreesitter", { clear = true }),
			callback = function(args)
				local buf = args.buf
				local ft = vim.bo[buf].filetype
				local lang = vim.treesitter.language.get_lang(ft)
				if not lang then
					return
				end

				-- Skip very large files, as the old `highlight.disable` did.
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return
				end

				if not pcall(vim.treesitter.start, buf, lang) then
					return
				end

				if not indent_disabled[ft] then
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end

				local opts = { buffer = buf, silent = true }
				vim.keymap.set("n", "gnn", init_selection, vim.tbl_extend("force", opts, { desc = "Init selection" }))
				vim.keymap.set("x", "grn", expand(false), vim.tbl_extend("force", opts, { desc = "Node incremental" }))
				vim.keymap.set("x", "grc", expand(true), vim.tbl_extend("force", opts, { desc = "Scope incremental" }))
				vim.keymap.set("x", "grm", shrink, vim.tbl_extend("force", opts, { desc = "Node decremental" }))
			end,
		})

		-- Custom filetype detection for Dockerfile-*
		vim.cmd([[
		  autocmd BufNewFile,BufRead Dockerfile-* setfiletype dockerfile
		]])

		-- Custom filetype detection for TypeScript declaration files
		vim.cmd([[
		  autocmd BufNewFile,BufRead *.d.mts setfiletype typescript
		  autocmd BufNewFile,BufRead *.d.cts setfiletype typescript
		  autocmd BufNewFile,BufRead *.mts setfiletype typescript
		  autocmd BufNewFile,BufRead *.cts setfiletype typescript
		]])
	end,
}
