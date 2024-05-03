return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
		-- vim.cmd([[autocmd FileType fugitive nnoremap <buffer> = r]])

		local Jacob_Fugitive = vim.api.nvim_create_augroup("Jacob_Fugitive", {})

		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = Jacob_Fugitive,
			pattern = "*",
			callback = function ()
				if vim.bo.ft ~= "fugitive" then
					return
				end

				local opts = { buffer = vim.api.nvim_get_current_buf(), remap = false, silent = true }
				vim.keymap.set("n", "<leader>P", function()
					vim.cmd.Git("push")
				end, opts)
				-- does not work vim.keymap.set("n", "r", ":<C-U>execute <SID>StageInline('toggle',line('.'),v:count)<CR>", opts)
			end
		})
	end
}
