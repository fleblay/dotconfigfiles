vim.cmd("source ~/.vimrc")

--1. install nvim-lspconfig
--git clone https://github.com/neovim/nvim-lspconfig.git
--2. install lsp servers using brew preferably
require'lspconfig'.tsserver.setup{}
--brew install vscode-langservers-extracted
require'lspconfig'.eslint.setup{}

--3. install nvim-tree
--git clone https://github.com/nvim-tree/nvim-tree.lua.git
--git clone https://github.com/nvim-tree/nvim-web-devicons.git
--install font from https://www.nerdfonts.com/font-downloads
--IBMPlexMono
--set the terminal to use it

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require("nvim-tree").setup()
require("nvim-web-devicons").setup()

vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>')

--4. install tree-sitter
--https://github.com/nvim-treesitter/nvim-treesitter.git
--Install languages (check with :TSInstallInfo
--:TSInstall typescript

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', 'sso', vim.diagnostic.open_float)
vim.keymap.set('n', 'ssp', vim.diagnostic.goto_prev)
vim.keymap.set('n', 'ssn', vim.diagnostic.goto_next)
--vim.keymap.set('n', 'ssl', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
	vim.keymap.set('i', '<C-k>', '<C-x><C-o>')

	vim.bo.tagfunc = 'v:lua.vim.lsp.tagfunc'
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('i', '<C-l>', vim.lsp.buf.signature_help, opts)
	--workspace
    vim.keymap.set('n', 'sfa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', 'sfr', vim.lsp.buf.remove_workspace_folder, opts)
	vim.keymap.set('n', 'sfl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'ssr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'gc', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'g=', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
