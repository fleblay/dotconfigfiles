vim.cmd("source ~/.vimrc")

--Use nvim as mergetool
vim.fn.system("git config --global mergetool nvim")
vim.fn.system("git config --global mergetool.nvim.cmd 'nvim -d -c \"wincmd l\" -c \"norm ]c\" \"$LOCAL\" \"$MERGED\" \"$REMOTE\"'")

--1. install nvim-lspconfig
--git clone https://github.com/neovim/nvim-lspconfig.git
--2. install lsp servers using brew preferably
require'lspconfig'.tsserver.setup{}
--brew install vscode-langservers-extracted
require'lspconfig'.eslint.setup{}
--brew install lua-language-server
require'lspconfig'.lua_ls.setup{
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

--3. install nvim-tree
--git clone https://github.com/nvim-tree/nvim-tree.lua.git
--git clone https://github.com/nvim-tree/nvim-web-devicons.git
--install font from https://www.nerdfonts.com/font-downloads
--IBMPlexMono
--set the terminal to use it

require("nvim-tree").setup()
require("nvim-web-devicons").setup()

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

vim.keymap.set('n', '<leader>to', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>tf', ':NvimTreeFindFile<CR>')

--USEFULL :
--P Parent directory
--< Previous sibling
--> Next sibling
--C-] CD
--o open

--4. install tree-sitter
--https://github.com/nvim-treesitter/nvim-treesitter.git
--Install languages (check with :TSInstallInfo
--:TSInstall typescript

require'nvim-treesitter.configs'.setup{
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

   -- List of parsers to ignore installing (or "all")
  ignore_install = { "javascript" },

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

--5. install theme with nvim-treesitter support
--https://github.com/folke/tokyonight.nvim.git

require("tokyonight").setup({
 style = "storm"
})

vim.cmd[[colorscheme tokyonight]]

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
	vim.keymap.set('i', '<C-k>', '<C-x><C-o>') --MOST USEFULL

	vim.bo.tagfunc = 'v:lua.vim.lsp.tagfunc'
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) --USEFULL
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts) --USEFULL
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('i', '<C-l>', vim.lsp.buf.signature_help, opts) --USEFULL
    vim.keymap.set('n', 'gl', vim.lsp.buf.signature_help, opts) --USEFULL
	--workspace
    vim.keymap.set('n', 'sfa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', 'sfr', vim.lsp.buf.remove_workspace_folder, opts)
	vim.keymap.set('n', 'sfl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'ssr', vim.lsp.buf.rename, opts) --USEFULL
    vim.keymap.set('n', 'gc', vim.lsp.buf.code_action, opts) --USEFULL
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'g=', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})
