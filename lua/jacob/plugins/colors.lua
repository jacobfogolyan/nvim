return {
-- string then github
 "catppuccin/nvim",
 config = function ()
	 require("catppuccin").setup({
		flavour = "frappe",
	 })
	 vim.cmd.colorscheme "catppuccin"
 end
}
