return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local trouble = require("trouble")
		trouble.setup {
			modes = {
				diagnostics = {
					-- Automatically open list when diagnostics are detected
					auto_open = true,
					-- Automatically close list when no diagnostics are detected
					auto_close = true,
					position = "bottom",
					mode = "workspace_diagnostics",
					-- Group results on a per-file basis.
					group = true,
					cycle_results = true,
					-- Show all severity levels
					severity = nil,
					padding = 0,
					-- Mappings for keymaps in the diagnostics window
					action_keys = {
						close = "q",
						refresh = "r",
						switch_severity = "s",
						preview = "p",
						previous = "k",
						next = "j",
						-- Opens a small popup with the full diagnostic message
						hover = "K",
					},
					multiline = true,
				},
			},
		}

		vim.keymap.set("n", "<leader>xx", function() trouble.toggle() end)
		vim.keymap.set("n", "<leader>xw", function() trouble.toggle("workspace_diagnostics") end)
		vim.keymap.set("n", "<leader>xd", function() trouble.toggle("document_diagnostics") end)
		vim.keymap.set("n", "<leader>xl", function() trouble.toggle("loclist") end)
		vim.keymap.set("n", "<leader>xq", function() trouble.toggle("quickfix") end)

--		local Jacob_Trouble = vim.api.nvim_create_augroup("Jacob_Trouble", {})
--		local autocmd = vim.api.nvim_create_autocmd
--
--		autocmd("BufDelete", {
--			group = Jacob_Trouble,
--			callback = function ()
--				local listed_buffers = vim.fn.getbufinfo({buflisted = 1})
--				if #listed_buffers == 1 and listed_buffers[1].name == 'NvimTree_1' then
--					vim.cmd('TroubleClose')
--				end
--			end
--		})
	end
}
