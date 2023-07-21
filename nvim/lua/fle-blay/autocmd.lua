--This autocmd will be triggered with the on_attach callback added to config passed to lsp_start_client
vim.api.nvim_create_autocmd('User', {
	pattern = 'LspAttached',
	desc = 'LSP actions',
	callback = function()
		--defining a bufmap function to create mapping for buffer
		local bufmap = function(mode, lhs, rhs)
			--only add keymap to current buffer
			local opts = {buffer = true}
			vim.keymap.set(mode, lhs, rhs, opts)
		end

		--Define omnifunc function (used with C-x + C-o)
		--v:lua prefix used to call lua fx
		--useful when in need for a "func" option
		--v:lua.somemod.func(args) same as return somemod.func(...)
		vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
		bufmap('i', '<C-k>', '<C-x><C-o>') -- USEFULL

		--use language server for tags when possible
		vim.bo.tagfunc = 'v:lua.vim.lsp.tagfunc'

		--Display hover info about symbol under cursor
		bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>') -- USEFULL

		--Jump to definition
		bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

		--Jump to declaration
		bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

		--Lists all implmentations for symbol under cursor
		bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

		--Jump to definition of the type symbol
		bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

		--List all the references
		bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

		--Displays a functions's signature info
		--bufmap({'i', 'n'}, '<C-l>', '<cmd>lua vim.lsp.buf.signature_help()<cr>') -- USEFULL, but prevent from clear noh
		bufmap('i', '<C-l>', '<cmd>lua vim.lsp.buf.signature_help()<cr>') -- USEFULL

		--Show disgnostics in a floating window
		bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

		--Move to previous diagnostic
		bufmap('n', 'ssp', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<cr>') -- USEFULL

		--Move to next diagnostic
		bufmap('n', 'ssn', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<cr>') -- USEFULL

		bufmap('n', 'gc', '<cmd>lua vim.lsp.buf.code_action()<cr>') -- USEFULL

		--No mapping for vim.lsp.buf.rename()
		--No mapping (x mode) for vim.lsp.buf.range_code_action()
		
		bufmap('n', 'g=', '<cmd>lua vim.lsp.buf.formatting()<cr>') -- USEFULL
	end
})
