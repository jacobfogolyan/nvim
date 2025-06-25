return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
		-- Define highlight groups for different folders
		vim.api.nvim_set_hl(0, 'GitStatusFrontend', { fg = '#00DC82', bold = true }) -- Nuxt Green
		vim.api.nvim_set_hl(0, 'GitStatusBackend', { fg = '#D84A66', bold = true }) -- Softer NestJS Red
		vim.api.nvim_set_hl(0, 'GitStatusPackages', { fg = '#F7B731', bold = true }) -- Swagger Yellow/Orange
		vim.api.nvim_set_hl(0, 'GitStatusOther', { fg = '#abb2bf' })           -- Gray
		local Jacob_Fugitive = vim.api.nvim_create_augroup("Jacob_Fugitive", {})
		local autocmd = vim.api.nvim_create_autocmd

		-- Function to apply syntax highlighting
		local function apply_git_syntax()
			vim.cmd([[
				syntax clear GitStatusFrontend GitStatusBackend GitStatusPackages
				syntax match GitStatusFrontend "apps/frontend/.*" contained containedin=ALL
				syntax match GitStatusBackend "apps/backend/.*" contained containedin=ALL
				syntax match GitStatusPackages "packages/.*" contained containedin=ALL
			]])
		end

		autocmd("BufWinEnter", {
			group = Jacob_Fugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end
				local opts = { buffer = vim.api.nvim_get_current_buf(), remap = false, silent = true }
				vim.keymap.set("n", "<leader>P", function()
					vim.cmd.Git("push")
				end, opts)
				-- Apply syntax highlighting
				apply_git_syntax()
			end
		})

		-- Reapply on various events that might clear syntax
		autocmd({ "WinEnter", "BufEnter", "FocusGained", "CursorHold" }, {
			group = Jacob_Fugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft == "fugitive" then
					vim.defer_fn(function()
						apply_git_syntax()
					end, 10)
				end
			end
		})

		-- Also hook into FileType event specifically for fugitive
		autocmd("FileType", {
			group = Jacob_Fugitive,
			pattern = "fugitive",
			callback = function()
				apply_git_syntax()
			end
		})

		-- Optional: Add status line indicator for current file's project
		autocmd("BufEnter", {
			group = Jacob_Fugitive,
			pattern = "*",
			callback = function()
				local path = vim.fn.expand('%:p')
				if path:match("apps/frontend") then
					vim.b.project_folder = "🟢 Nuxt"
				elseif path:match("apps/backend") then
					vim.b.project_folder = "🔴 Nest"
				elseif path:match("packages") then
					vim.b.project_folder = "📦 Types"
				else
					vim.b.project_folder = nil
				end
			end
		})
	end
}
