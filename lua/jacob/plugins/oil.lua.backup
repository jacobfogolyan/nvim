return {
	"stevearc/oil.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local oil = require("oil")

		oil.setup {
			-- Takeover default netrw explorer
			default_file_explorer = true,
			columns = {
				"icon",
				"permissions",
				"size",
			},
			view_options = {
				show_hidden = true,
			},
			lsp_file_methods = {
				enabled = true
			},
			-- Add keymaps for opening all files in a directory
			keymaps = {
				["<leader>a"] = {
					callback = function()
						-- Get the entry under the cursor
						local entry = oil.get_cursor_entry()
						if not entry then
							vim.notify("No entry under cursor", vim.log.levels.ERROR)
							return
						end

						-- Check if it's a directory
						if entry.type ~= "directory" then
							vim.notify("Not a directory under cursor", vim.log.levels.ERROR)
							return
						end

						local current_dir = oil.get_current_dir()
						local target_dir = vim.fn.fnamemodify(current_dir .. "/" .. entry.name, ":p")

						-- Function to recursively get all files in a directory
						local function get_all_files(dir, files)
							files = files or {}
							local handle = vim.loop.fs_scandir(dir)
							if not handle then
								vim.notify("Failed to read directory: " .. dir, vim.log.levels.ERROR)
								return files
							end

							while true do
								local name, type = vim.loop.fs_scandir_next(handle)
								if not name then break end

								local full_path = dir .. "/" .. name

								if type == "file" then
									table.insert(files, vim.fn.fnameescape(full_path))
								elseif type == "directory" then
									-- Recursively get files from subdirectories
									get_all_files(full_path, files)
								end
							end

							return files
						end

						-- Get all files recursively
						local files_to_open = get_all_files(target_dir)

						if #files_to_open == 0 then
							vim.notify("No files found in directory", vim.log.levels.INFO)
							return
						end

						-- Confirm with user if there are many files
						if #files_to_open > 10 then
							local confirmed = vim.fn.confirm("Open " .. #files_to_open .. " files?", "&Yes\n&No", 2)
							if confirmed ~= 1 then return end
						end

						-- Open all files
						for _, file_path in ipairs(files_to_open) do
							vim.cmd("edit " .. file_path)
						end

						vim.notify("Opened " .. #files_to_open .. " files from " .. entry.name, vim.log.levels.INFO)
					end,
					desc = "Open all files in directory under cursor"
				}
			}
		}

		vim.keymap.set("n", "<C-o>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end
}

