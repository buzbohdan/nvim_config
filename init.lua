local map = vim.keymap.set

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '
map('n', '<leader>hh', '<cmd>nohlsearch<CR>')
map('n', '<leader><c-q>', ':wqa<cr>')
map('n', '<leader>a', '<c-^>')
map('n', '<leader>y', '"+y')
map('n', '<leader>p', '"+p')
map('n', '<leader>w', '<cmd>w<CR>')
map('n', '<leader>p', '<c-w>p')

require('lazy').setup(
  {
    'tpope/vim-sleuth',
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        options = {
          theme = 'sonokai',
          disabled_filetypes = {
            statusline = { 'NeogitStatus', 'NvimTree', 'Outline' },
          },
        },
        sections = {
          lualine_a = {
            { 'mode', fmt = function(mode) return mode:sub(1, 1) end },
            function() return vim.fn.fnamemodify(vim.fn.getcwd(), ':t') end,
          },
          lualine_c = { { 'filename', path = 1 }, },
          lualine_x = {},
        },
        inactive_sections = {
          lualine_c = { { 'filename', path = 1 } },
        },
      },
    },
    {
      'stevearc/conform.nvim',
      opts = {
        formatters_by_ft = { xml = { 'xmlformat' } },
        formatters = {
          xmlformat = { command = '~/.local/bin/xmlformat' },
        }
      }
    },
    {
      'nvimdev/lspsaga.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require('lspsaga').setup({
          symbol_in_winbar = { show_file = false },
          finder = { left_width = 0.2 },
          lightbulb = { sign = false },
        })
        map('n', '<leader>sp', '<cmd>Lspsaga peek_definition<CR>')
        map('n', '<leader>sa', '<cmd>Lspsaga code_action<CR>')
        map('n', '<leader>sf', '<cmd>Lspsaga finder<CR>')
        map('n', '<leader>st', '<cmd>Lspsaga term_toggle<CR>')
        map('n', '<leader>sh', '<cmd>Lspsaga hover_doc<CR>')
        map('n', '<leader>sr', '<cmd>Lspsaga rename<CR>')
      end
    },
    {
      'folke/trouble.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
    },
    {
      'echasnovski/mini.nvim',
      version = false,
      config = function()
        require('mini.comment').setup()
        require('mini.sessions').setup { autoread = true }

        require('mini.bufremove').setup {}
        map('n', '<leader>bd', MiniBufremove.delete)
      end
    },
    {
      'hedyhli/outline.nvim',
      config = function()
        local outline = require('outline')
        vim.keymap.set('n', '<leader>so', outline.toggle, { desc = 'Toggle Outline' })

        outline.setup {
          symbols = { filter = { 'Variable', exclude = true } },
        }
      end,
    },
    {
      'sainnhe/sonokai',
      dependencies = { { 'catppuccin/nvim', name = 'catppuccin' } },
      priority = 1000,
      config = function ()
        -- Need to activate `catppuccin` first, otherwise Neogit doesn' have color (no idea why)
        vim.cmd.colorscheme 'catppuccin'
        vim.cmd.colorscheme 'sonokai'
      end
    },
    {
      'lewis6991/gitsigns.nvim',
      opts = {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        numhl = true,
        on_attach = function()
          local gitsigns = require('gitsigns')
          map('n', '<leader>ht', gitsigns.setqflist)
          map('n', '<leader>hs', gitsigns.stage_hunk)
          map('n', '<leader>hu', gitsigns.undo_stage_hunk)
          map('n', '<leader>hr', gitsigns.reset_hunk)
          map('n', '<leader>hp', gitsigns.preview_hunk)
          map('n', '<leader>hd', gitsigns.toggle_deleted)
          map('n', '<leader>hb', gitsigns.blame_line)
        end
      },
    },
    {
      'NeogitOrg/neogit',
      tag = 'v0.0.1',
      dependencies = {
        'nvim-lua/plenary.nvim',  -- required
        'sindrets/diffview.nvim', -- optional - Diff integration

        -- Only one of these is needed, not both.
        -- 'nvim-telescope/telescope.nvim', -- optional
        'ibhagwan/fzf-lua', -- optional
      },
      config = function()
        local neogit = require('neogit')
        neogit.setup { disable_hint = true }
        map('n', '<leader>gg', '<cmd>Neogit kind=vsplit<CR>')
        map('n', '<leader>gf', '<cmd>Neogit cwd=%:p:h kind=vsplit<CR>')
      end
    },
    {
      'ray-x/lsp_signature.nvim',
      event = 'VeryLazy',
      opts = { hint_enable = false },
    },
    {
      'ibhagwan/fzf-lua',
      -- optional for icon support
      dependencies = {
        'nvim-tree/nvim-web-devicons',
        'rktjmp/lush.nvim',
      },
      config = function()
        -- calling `setup` is optional for customization
        require('fzf-lua').setup({})
      end
    },
    {
      'neovim/nvim-lspconfig',
      config = function()
        local lspconfig = require('lspconfig')

        lspconfig.pyright.setup({})
        lspconfig.jsonls.setup({})
        lspconfig.lua_ls.setup({
          settings = {
            Lua = {
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim', 'MiniSessions', 'MiniBufremove' },
              },
            },
          }
        })
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', '<leader>lD', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<leader>lic', vim.lsp.buf.incoming_calls, opts)
            vim.keymap.set('n', '<leader>loc', vim.lsp.buf.outgoing_calls, opts)
            vim.keymap.set('n', '<leader>lds', vim.lsp.buf.document_symbol, opts)
            vim.keymap.set('n', '<leader>lws', vim.lsp.buf.workspace_symbol, opts)
            vim.keymap.set('n', '<leader>lR', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'v' }, '<leader>la', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<leader>lr', '<cmd>TroubleToggle lsp_references<cr>', opts)
            vim.keymap.set('n', '<leader>lf', function()
              vim.lsp.buf.format { async = true }
            end, opts)
          end,
        })
      end
    },
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-refactor',
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      config = function()
        require('nvim-treesitter.configs').setup({
          ensure_installed = { 'c', 'lua', 'vim', 'vimdoc', 'query', 'scala', 'rust', 'python', 'json', 'markdown', 'markdown_inline' },
          highlight = { enable = true },
          indent = { enable = true },
          incremental_selection = {
            enable = true,
            keymap = {
              init_selection = 'gnn', node_incremental = '<M-i>', node_decremental = '<M-I>', }
          },
          textobjects = {
            move = {
              enable = true,
              set_jumps = true,
              goto_next_start = {
                ['<leader>nf'] = '@function.outer',
              },
            }
          },
          refactor = {
            highlight_definitions = {
              enable = true,
              -- Set to false if you have an `updatetime` of ~100.
              clear_on_cursor_move = false
            },
          },
        })
      end
    },
    { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          build = [[cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release \
          && cmake --build build --config Release \
          && cmake --install build --prefix build]]
        },
        'nvim-telescope/telescope-live-grep-args.nvim',
        'nvim-telescope/telescope-frecency.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-tree/nvim-web-devicons',
        'nvim-telescope/telescope-ui-select.nvim',
      },

      opts = function()
        local builtin = require('telescope.builtin')
        local telescope = require('telescope')

        map('n', '<leader>fa', function() builtin.find_files { no_ignore = false } end)
        map('n', '<leader>ff', function() telescope.extensions.frecency.frecency {} end)
        map('n', '<leader>fb', builtin.buffers, {})
        map('n', '<leader>fg', telescope.extensions.live_grep_args.live_grep_args)
        map('n', '<leader>fgg', builtin.grep_string, {})
        map('n', '<leader>fc', builtin.commands, {})
        map('n', '<leader>fo', builtin.oldfiles, {})
        map('n', '<leader>fh', builtin.command_history, {})
        map('n', '<leader>fs', builtin.search_history, {})
      end,
      config = function()
        local telescope = require 'telescope'
        local lga_actions = require('telescope-live-grep-args.actions')
        telescope.setup {
          extensions = {
            live_grep_args = {
              mappings = {
                i = {
                  ['<C-k>'] = lga_actions.quote_prompt(),
                  ['<C-i>'] = lga_actions.quote_prompt({ postfix = ' --iglob ' }),
                },
              },
            },
            ['ui-select'] = {
              require('telescope.themes').get_dropdown(),
            },
          },
        }
        telescope.load_extension('fzf')
        telescope.load_extension('ui-select')
        telescope.load_extension('live_grep_args')
        telescope.load_extension('frecency')
      end
    },
    {
      'nvim-tree/nvim-tree.lua',
      version = '*',
      lazy = false,
      dependencies = {
        'nvim-tree/nvim-web-devicons',
      },
      config = function()
        require('nvim-tree').setup { filters = { exclude = { 'local.py', 'local_settings.py' } } }
        map('n', '<leader>tt', '<cmd>:NvimTreeToggle<cr>')
        map('n', '<leader>tf', '<cmd>:NvimTreeFocus<cr>')
        map('n', '<leader>tr', '<cmd>:NvimTreeFindFile<cr>')
        map('n', '<leader>tc', '<cmd>:NvimTreeCollapseKeepBuffers<cr>')

        -- Disabling netrw
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
      end
    },
    {
      'SmiteshP/nvim-navbuddy',
      dependencies = {
        'neovim/nvim-lspconfig',
        'SmiteshP/nvim-navic',
        'MunifTanjim/nui.nvim',
      },
      config = function()
        local navbuddy = require('nvim-navbuddy')
        navbuddy.setup({
          lsp = { auto_attach = true },
          window = {
            border = 'rounded',
            size = { width = '80%', height = '40%' },
            position = { row = '100%', col = '80%' },
          },
          source_buffer = { reorient = 'top', scrolloff = 2 },
        })
        map('n', '<leader>nn', navbuddy.open)
      end
    },
    {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      dependencies = {
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-vsnip' },
        { 'hrsh7th/vim-vsnip' },
        { 'onsails/lspkind.nvim' },
      },
      config = function()
        local cmp = require('cmp')
        cmp.setup({
          sources = {
            { name = 'nvim_lsp' },
            { name = 'vsnip' },
            { name = 'buffer' },
          },
          snippet = {
            expand = function(args)
              -- Comes from vsnip
              vim.fn['vsnip#anonymous'](args.body)
            end,
          },
          formatting = {
            format = require('lspkind').cmp_format({})
          },
          window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
          },
          mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({ select = true })
          })
        })
      end,
    },
    {
      'mfussenegger/nvim-dap',
      config = function()
        local dap = require('dap')
        dap.configurations.scala = { {
          type = 'scala',
          request = 'launch',
          name = 'Run or Test Target',
          metals = {
            runType = 'runOrTestFile',
          },
        } }

        map('n', '<leader>db', dap.toggle_breakpoint)
        map('n', '<leader>dc', dap.continue)
        map('n', '<leader>dv', function()
          dap.repl.open({}, 'belowright vsplit')
        end)
      end
    },
    {
      'scalameta/nvim-metals',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'mfussenegger/nvim-dap',
        {
          'j-hui/fidget.nvim',
          opts = { notification = { window = { winblend = 0, border = 'rounded' } } },
        },
      },
      ft = { 'scala', 'sbt' },
      opts = function()
        local metals_config = require('metals').bare_config()

        metals_config.init_options.statusBarProvider = 'off'

        metals_config.showInferredType = true
        metals_config.showImplicitConversionsAndClasses = true
        metals_config.showImplicitArguments = true

        -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
        metals_config.capabilities = require('cmp_nvim_lsp').default_capabilities()

        metals_config.on_attach = function()
          require('metals').setup_dap()

          map('n', '<leader>ws', function()
            require('metals').hover_worksheet()
          end)

          -- all workspace diagnostics
          map('n', '<leader>aa', vim.diagnostic.setqflist)

          -- all workspace errors
          map('n', '<leader>ae', function()
            vim.diagnostic.setqflist({ severity = 'E' })
          end)

          -- all workspace warnings
          map('n', '<leader>aw', function()
            vim.diagnostic.setqflist({ severity = 'W' })
          end)

          -- buffer diagnostics only
          map('n', '<leader>d', vim.diagnostic.setloclist)

          map('n', '[c', function()
            vim.diagnostic.goto_prev({ wrap = false })
          end)

          map('n', ']c', function()
            vim.diagnostic.goto_next({ wrap = false })
          end)
        end

        return metals_config
      end,
      config = function(self, metals_config)
        local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
        vim.api.nvim_create_autocmd('FileType', {
          pattern = self.ft,
          callback = function()
            require('metals').initialize_or_attach(metals_config)
          end,
          group = nvim_metals_group,
        })
      end

    }
  },
  { ui = { border = 'rounded' } }
)

-- global
vim.opt_global.completeopt = { 'menuone', 'noinsert', 'noselect' }

vim.o.number = 1
vim.o.cursorline = 1
vim.o.ignorecase = 1
vim.o.smartcase = 1
vim.o.autoindent = 1
vim.o.expandtab = 1
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.confirm = 2
vim.o.updatetime = 250
vim.o.scrolloff = 5
vim.o.mouse = 'a'

vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath('config') .. '/undo/'

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

