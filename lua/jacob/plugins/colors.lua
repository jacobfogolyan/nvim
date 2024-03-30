return {
-- string is github url without gihub.com at start
 "catppuccin/nvim",
 config = function ()
	 require("catppuccin").setup({
		flavour = "frappe",
	 })
	 vim.cmd.colorscheme "catppuccin"
 end
}
