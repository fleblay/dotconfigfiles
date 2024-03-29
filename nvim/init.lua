--TODO : Fix shortcut for completion
--TODO : Remove mapping for finding files from vimrc
--TODO : Use default mapping for nvim_lsp_config and replace replace space by backtick ?

--Source old vimrc file
vim.cmd("source ~/.vimrc")
vim.g.mapleader = " "

--Use nvim as mergetool
vim.fn.system("git config --global core.editor nvim")
vim.fn.system("git config --global mergetool nvim")
vim.fn.system(
  "git config --global mergetool.nvim.cmd 'nvim -d -c \"wincmd l\" -c \"norm ]c\" \"$LOCAL\" \"$MERGED\" \"$REMOTE\"'")
vim.fn.system("git config --global mergetool.keepBackup false")

--Use lazy as a package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup(
  {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        require("tokyonight").setup({
          style = "storm"
        })
        vim.cmd([[colorscheme tokyonight]])
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        local configs = require("nvim-treesitter.configs")

        ---@diagnostic disable-next-line missing-fields
        configs.setup({
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "typescript", "bash", "html", "javascript", "json",
            "markdown", "tsx", "yaml" },
          sync_install = false,
          auto_install = true,
          ignore_install = { "javascript" },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
      end
    },
    {
      --install font from https://www.nerdfonts.com/font-downloads
      --IBMPlexMono
      "nvim-tree/nvim-tree.lua",
      lazy = false,
      dependencies = {
        "nvim-tree/nvim-web-devicons"
      },
      keys = {
        { "<leader>tt", "<cmd>NvimTreeToggle<cr>",   desc = "Toggle Tree" },
        { "<leader>tf", "<cmd>NvimTreeFindFile<cr>", desc = "Find File in Tree" },
        --USEFULL :
        --P Parent directory
        --< Previous sibling
        --> Next sibling
        --C-] CD
        --o open
      },
      config = function()
        -- disable netrw at the very start of your init.lua
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        -- set termguicolors to enable highlight groups
        vim.opt.termguicolors = true
        require("nvim-tree").setup()
      end
    },
    {
      'nvim-lualine/lualine.nvim',
      dependencies = {
        'nvim-tree/nvim-web-devicons'
      },
      config = true
    },
    {
      --brew install ripgrep for better performance
      'nvim-telescope/telescope.nvim',
      branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        require("telescope").setup({})
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      end
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {{"folke/neodev.nvim", opts = {} }},
      config = function()
        -- Global mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        vim.keymap.set('n', 'sso', vim.diagnostic.open_float)
        vim.keymap.set('n', 'ssp', vim.diagnostic.goto_prev)
        vim.keymap.set('n', 'ssn', vim.diagnostic.goto_next)
        vim.keymap.set('n', 'ssl', vim.diagnostic.setloclist)

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            vim.bo.tagfunc = 'v:lua.vim.lsp.tagfunc' -- usefull ?
            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)        --USEFULL
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)              --USEFULL
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts) --USEFULL
            --workspace
            vim.keymap.set('n', 'sfa', vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set('n', 'sfr', vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set('n', 'sfl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set('n', 'gtd', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', 'ssr', vim.lsp.buf.rename, opts)              --USEFULL
            vim.keymap.set({ 'n', 'v' }, 'gc', vim.lsp.buf.code_action, opts) --USEFULL
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', 'g=', function()
              vim.lsp.buf.format { async = true }
            end, opts)
          end,
        })
      end
    },
    {
      "mfussenegger/nvim-dap",
      dependencies = {
        "rcarriga/nvim-dap-ui",
        "mxsdev/nvim-dap-vscode-js",
        -- build debugger from source
        {
          "microsoft/vscode-js-debug",
          version = "1.x",
          build = "npm i && npm run compile vsDebugServerBundle && mv dist out"
        }
      },
      keys = {
        -- normal mode is default
        { "<leader>db", function() require 'dap'.toggle_breakpoint() end },
        { "<leader>dd", function() require 'dap'.continue() end },
        { "<leader>dv", function() require 'dap'.step_over() end },
        { "<leader>di", function() require 'dap'.step_into() end },
        { "<leader>do", function() require 'dap'.step_out() end },
      },
      config = function()
        require('dap').set_log_level('DEBUG')
        ---@diagnostic disable-next-line missing-fields
        require("dap-vscode-js").setup({
          debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
          adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost', 'node', 'chrome' },
        })

        local js_based_languages = { "typescript", "javascript", "typescriptreact" }

        for _, language in ipairs(js_based_languages) do
          require("dap").configurations[language] = {
            -- attach to a node process that has been started with
            -- `--inspect` for longrunning tasks or `--inspect-brk` for short tasks
            -- npm script -> `node --inspect-brk ./node_modules/.bin/vite dev`
            {
              request = "attach",
              name = "Attach debugger with .vscode rule",
              resolveSourceMapLocations = nil,
              sourceMapPathOverrides = {
                "*", "${workspaceFolder}/*"
              },
              localRoot = vim.loop.cwd(),
              sourceMaps = true,
              type = "pwa-node", --pwa-node
              continueOnAttach = true,
              internalConsoleOptions = "neverOpen"
            },
            {
              -- use nvim-dap-vscode-js's pwa-node debug adapter
              type = "pwa-node",
              -- attach to an already running node process with --inspect flag
              -- default port: 9222
              request = "attach",
              -- allows us to pick the process using a picker
              processId = require 'dap.utils'.pick_process,
              -- name of the debug action you have to select for this config
              name = "Attach debugger to existing `node --inspect` process",
              -- for compiled languages like TypeScript or Svelte.js
              sourceMaps = true,
              -- resolve source maps in nested locations while ignoring node_modules
              resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**" },
              -- path to src in vite based projects (and most other projects as well)
              cwd = "${workspaceFolder}/src",
              -- we don't want to debug code inside node_modules, so skip it!
              skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
            },
            {
              type = "pwa-chrome",
              name = "Launch Chrome to debug client",
              request = "launch",
              url = "http://localhost:5173", -- TO BE CHANGED
              sourceMaps = true,
              protocol = "inspector",
              port = 9222,
              webRoot = "${workspaceFolder}/src",
              -- skip files from vite's hmr
              skipFiles = { "**/node_modules/**/*", "**/@vite/*", "**/src/client/*", "**/src/*" },
            },
            -- only if language is javascript, offer this debug action
            language == "javascript" and {
              -- use nvim-dap-vscode-js's pwa-node debug adapter
              type = "pwa-node",
              -- launch a new process to attach the debugger to
              request = "launch",
              -- name of the debug action you have to select for this config
              name = "Launch file in new node process",
              -- launch current file
              program = "${file}",
              cwd = "${workspaceFolder}",
            } or nil,
          }
        end

        require("dapui").setup()
        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open({ reset = true })
        end
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close

        vim.keymap.set('n', '<leader>du', require 'dapui'.toggle)
      end
    },
    {
      'hrsh7th/nvim-cmp',
      dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/nvim-cmp',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        { 'neovim/nvim-lspconfig',
          {
            dependencies = {
              'folke/neodev.nvim', opts = {}
            }
          }
        }
      },
      config = function()
        local cmp = require 'cmp'
        ---@diagnostic disable-next-line missing-fields
        cmp.setup({
          snippet = {
            expand = function(args)
              require('luasnip').lsp_expand(args.body)
            end,
          },
          ---@diagnostic disable-next-line missing-fields
          window = {
            -- completion = cmp.config.window.bordered(),
            -- documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<S-Space>'] = cmp.mapping.complete(),            --FIXME
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' }, -- For luasnip users.
          }, {
            { name = 'buffer' },
          })
        })

        -- Set configuration for specific filetype.
        ---@diagnostic disable-next-line missing-fields
        cmp.setup.filetype('gitcommit', {
          sources = cmp.config.sources({
            { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
          }, {
            { name = 'buffer' },
          })
        })

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        ---@diagnostic disable-next-line missing-fields
        cmp.setup.cmdline({ '/', '?' }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = 'buffer' }
          }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        ---@diagnostic disable-next-line missing-fields
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          })
        })

        -- Set up lspconfig.
        -- FIXME -> Use a loop
        -- FIXME -> Add JSON capabilities
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        --brew install typescript-language-server
        require 'lspconfig'.tsserver.setup {
          capabilities = capabilities
        }

        --brew install vscode-langservers-extracted
        require 'lspconfig'.eslint.setup({
          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
          capabilities = capabilities
        })

        --brew install lua-language-server
        require 'lspconfig'.lua_ls.setup {
          on_init = function(client)
            local path = client.workspace_folders[1].name
            if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
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
          end,
          capabilities = capabilities
        }

        --brew install gopls
        require 'lspconfig'.gopls.setup {
          capabilities = capabilities
        }

        --brew install vscode-langservers-extracted
        require 'lspconfig'.jsonls.setup {
          capabilities = capabilities
        }
      end,
    },
    {
      "folke/persistence.nvim",
      event = "BufReadPre",
      opts = { options = vim.opt.sessionoptions:get() },
      -- stylua: ignore
      keys = {
        { "<leader>qs", function() require("persistence").load() end,                desc = "Restore Session" },
        { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
        { "<leader>qd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
      },
    },
  }
)
