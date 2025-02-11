_G.get_args = function()
  -- 获取输入命令行参数
  local cmd_args = vim.fn.input('CommandLine Args:')
  local params = {}
  -- 定义分隔符(%s在lua内表示任何空白符号)
  local sep = "%s"
  for param in string.gmatch(cmd_args, "[^%s]+") do
    table.insert(params, param)
  end
  return params
end

return {
	"mfussenegger/nvim-dap",
	recommended = true,
	desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",

	dependencies = {
		"rcarriga/nvim-dap-ui",
		{
			"williamboman/mason.nvim",
			opts = function(_, opts)
				opts.ensure_installed = opts.ensure_installed or {}
				table.insert(opts.ensure_installed, "js-debug-adapter")
			end,
		},
		-- virtual text for the debugger
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {},
		},
		{
			"theHamsta/nvim-dap-virtual-text",
			opts = {},
		},
		{
			"rcarriga/nvim-dap-ui",
			dependencies = { "nvim-neotest/nvim-nio" },
			-- stylua: ignore
			keys = {
				{ "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
				{ "<leader>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
			},
			opts = {},
			config = function(_, opts)
				local dap = require("dap")
				local dapui = require("dapui")
				dapui.setup(opts)
				dap.listeners.after.event_initialized["dapui_config"] = function()
					dapui.open({})
				end
				dap.listeners.before.event_terminated["dapui_config"] = function()
					dapui.close({})
				end
				dap.listeners.before.event_exited["dapui_config"] = function()
					dapui.close({})
				end
			end,
		},
		{ "nvim-neotest/nvim-nio" },
		{
			"jay-babu/mason-nvim-dap.nvim",
			dependencies = "mason.nvim",
			cmd = { "DapInstall", "DapUninstall" },
			opts = {
				-- Makes a best effort to setup the various debuggers with
				-- reasonable debug configurations
				automatic_installation = true,

				-- You can provide additional configuration to the handlers,
				-- see mason-nvim-dap README for more information
				handlers = {},

				-- You'll need to check that you have the required things installed
				-- online, please don't ask me how to install them :)
				ensure_installed = {
					-- Update this to ensure that you have the debuggers for the langs you want
				},
			},
			-- mason-nvim-dap is loaded when nvim-dap loads
			config = function() end,
		}
	},

	opts = function()
		local dap = require("dap")
		local LazyVim = require("lazyvim")

		if not dap.adapters["pwa-node"] then
			require("dap").adapters["pwa-node"] = {
				type = "server",
				host = "localhost",
				port = "${port}",
				executable = {
					command = "node",
					-- 💀 Make sure to update this path to point to your installation
					args = {
						LazyVim.get_pkg_path("js-debug-adapter", "/js-debug/src/dapDebugServer.js"),
						"${port}",
					},
				},
			}
		end
		if not dap.adapters["node"] then
			dap.adapters["node"] = function(cb, config)
				if config.type == "node" then
					config.type = "pwa-node"
				end
				local nativeAdapter = dap.adapters["pwa-node"]
				if type(nativeAdapter) == "function" then
					nativeAdapter(cb, config)
				else
					cb(nativeAdapter)
				end
			end
		end

		local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

		local vscode = require("dap.ext.vscode")
		vscode.type_to_filetypes["node"] = js_filetypes
		vscode.type_to_filetypes["pwa-node"] = js_filetypes

		for _, language in ipairs(js_filetypes) do
			if not dap.configurations[language] then
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
				}
			end
		end
	end,
	-- stylua: ignore
	keys = {
		{ "<leader>d",  "",                                                                                   desc = "+debug",                 mode = { "n", "v" } },
		{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
		{ "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
		{ "<leader>dc", function() require("dap").continue() end,                                             desc = "Continue" },
		{ "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
		{ "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
		{ "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
		{ "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
		{ "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
		{ "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
		{ "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
		{ "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
		{ "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
		{ "<leader>dp", function() require("dap").pause() end,                                                desc = "Pause" },
		{ "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
		{ "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
		{ "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
		{ "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
	},

	config = function()
		local LazyVim = require("lazyvim")
		-- load mason-nvim-dap here, after all adapters have been setup
		if LazyVim.has("mason-nvim-dap.nvim") then
			require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
		end

		vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

		for name, sign in pairs(LazyVim.config.icons.dap) do
			sign = type(sign) == "table" and sign or { sign }
			vim.fn.sign_define(
				"Dap" .. name,
				{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
			)
		end

		-- setup dap config by VsCode launch.json file
		local vscode = require("dap.ext.vscode")
		-- Extends dap.configurations with entries read from .vscode/launch.json
		if vim.fn.filereadable(".vscode/launch.json") then
			vscode.load_launchjs()
		end
	end,
}
