require("fle-blay.lsp")
require("fle-blay.autocmd")
require("fle-blay.utils_lsp")

vim.cmd("source ~/.vimrc")

local launch_server = function(language)
	if not active_servers then
		active_servers = {}
	end
	if active_servers[language] == true then
		print("Server is already launched for : " .. language)
		return
	end
	local filetypes = make_filetypes(language)
	local config = make_config(language)
	if (filetypes == nil or config == nil) then
		print("Unsupported server type : " .. language)
		return
	end
	set_default_config(config, filetypes)
	vim.lsp.start_client(config)
	active_servers[language] = true
end

-- creates a new user command with ({name}, {command}, {*opts})
vim.api.nvim_create_user_command(
	'LaunchServer',
	function(var)
		if (var.args == nil) then print("Need args to launch LSP server") return end
		print("Launching server " .. var.args)
		launch_server(var.args)
	end,
	{
		desc = 'Starting server',
		nargs = 1,
		complete = function()
			return {'cpp', 'ts', 'html', 'go'}
		end
	}
)
