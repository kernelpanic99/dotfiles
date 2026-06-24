-- vim: foldmethod=marker shiftwidth=2 foldlevel=0
-- zo - open section, zc - close section, zR - open all, zM - close all

--{{{Util
local function break_sentence(text, max_len)
  local chunks, current = {}, ''

  for word in text:gmatch('%S+') do
    local next_chunk = current == '' and word or current .. ' ' .. word

    if #next_chunk <= max_len then
      current = next_chunk
    else
      if current ~= '' then
        table.insert(chunks, current)
      end

      current = word
    end
  end

  if current ~= '' then
    table.insert(chunks, current)
  end

  return chunks
end
--}}}

-- {{{ Options

-- General Behaviour
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300 -- timeout for key chords
vim.o.confirm = true -- ask to save when quitting with unsaved changes

-- Hide '~' character on empty lines
vim.opt.fillchars = { eob = ' ' }

-- Identation
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.breakindent = true
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- UI
vim.g.have_nerd_font = true
vim.o.mouse = 'a'
vim.o.number = true
vim.o.showmode = false
vim.o.signcolumn = 'yes'
vim.o.splitright = true -- split to the right vertically
vim.o.splitbelow = true -- split down horizontally
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.opt.termguicolors = true

-- Search and replace
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split' -- previev substitutions live

-- Disable NETRW (native file explorer) and status line
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.o.laststatus = 0

-- Folds
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevelstart = 99

-- }}}

-- {{{ Check executables
local executables = { 'rg', 'lazygit', 'fzf', 'fd', 'git', 'tmux', 'lsof' }
local missing = {}

for _, exe in ipairs(executables) do
  if vim.fn.executable(exe) ~= 1 then
    vim.fn.system(exe)

    if vim.v.shell_error ~= 0 then
      table.insert(missing, exe)
    end
  end
end

if #missing > 0 then
  error(string.format('Missing required programs: %s', table.concat(missing, ', ')))
end
-- }}}

-- {{{ Languages
local function lsp_configs()
  -- {{{ Typescript
  vim.lsp.config('vtsls', {
    -- explicitly add default filetypes, so that we can extend
    -- them in related extras
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    },
    settings = {
      complete_function_calls = true,
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
        experimental = {
          maxInlayHintLength = 30,
          completion = {
            enableServerSideFuzzyMatch = true,
          },
        },
      },
      typescript = {
        updateImportsOnFileMove = { enabled = 'always' },
        suggest = {
          completeFunctionCalls = true,
        },
        inlayHints = {
          enumMemberValues = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          parameterNames = { enabled = 'literals' },
          parameterTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          variableTypes = { enabled = false },
        },
      },
    },
  })
  -- }}}

  -- {{{ Gdscript
  vim.lsp.config('gdscript', {
    cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
    filetypes = { 'gd', 'gdscript', 'gdscript3' },
    root_markers = { 'project.godot', '.git' },
  })
  vim.lsp.enable('gdscript')
  -- }}}

  for _, server in ipairs({
    'vtsls',
    'cssls',
    'tailwindcss',
    'astro',
    'svelte',
    'rust_analyzer',
    'gopls',
    'marksman',
    'yamlls',
    'terraformls',
    'lua_ls',
    'dockerls',
    'docker_compose_language_service',
    'bashls',
    'fish_lsp',
    'pyright',
    'zls',
    'nixd',
    'tombi',
  }) do
    vim.lsp.enable(server)
  end
end
-- }}}

-- {{{ Plugins

local plugin = {
  -- {{{ Libraries
  { 'nvim-tree/nvim-web-devicons', lazy = true }, -- Icons for some UI libraries
  { 'nvim-lua/plenary.nvim', lazy = true }, -- Utility Lua functions
  { 'MunifTanjim/nui.nvim' },
  {
    'antosha417/nvim-lsp-file-operations',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-tree.lua',
    },
    opts = {},
  },
  {
    dir = vim.g.treesitter_path,
    name = 'nvim-treesitter',
    lazy = false,
    config = function()
      require('nvim-treesitter').setup({
        highlight = { enable = true },
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)

          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldmethod = 'expr'
        end,
      })
    end,
  },
  -- }}}

  -- {{{ Colorschemes
  {
    'vague-theme/vague.nvim',
    priority = 1000,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = { flavour = 'macchiato' },
  },
  {
    'everviolet/nvim',
    name = 'evergarden',
    priority = 1000,
    opts = {
      theme = {
        variant = 'fall', -- 'winter'|'fall'|'spring'|'summer'
        accent = 'green',
      },
      editor = {
        transparent_background = false,
        sign = { color = 'none' },
        float = {
          color = 'mantle',
          solid_border = false,
        },
        completion = {
          color = 'surface0',
        },
      },
    },
  },
  {
    'webhooked/kanso.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      theme = 'mist',
    },
  },
  { 'folke/tokyonight.nvim' },
  { 'ellisonleao/gruvbox.nvim' },
  -- }}}

  -- {{{ Code
  { 'NMAC427/guess-indent.nvim' },
  { 'nvim-mini/mini.surround', version = false, opts = {} },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { '<leader>cw', '<cmd>TSJToggle<CR>', desc = 'Break/join [W]rap' },
    },
    opts = {
      max_join_length = 300,
    },
  },
  { 'nvim-mini/mini.pairs', version = false, event = 'InsertEnter', opts = {} },
  { 'qwavies/smart-backspace.nvim', opts = { map_bs = false } },
  { 'nvim-mini/mini.ai', version = false },
  {
    'chrisgrieser/nvim-puppeteer',
    lazy = false,
    config = function()
      vim.g.puppeteer_js_quotation_mark = "'"
    end,
  },
  { 'gbprod/cutlass.nvim', opts = { cut_key = 'd' } },
  { 'dmmulroy/ts-error-translator.nvim', opts = {} },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    opts = {},
  },
  -- }}}

  -- {{{ Navigation
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigatorProcessList',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
  -- }}}

  -- {{{ Keybindings
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
    config = function()
      local wk = require('which-key')

      wk.add({
        -- Group definitions
        { '<leader>b', group = '[B]uffer' },
        { '<leader>c', group = '[C]ode' },
        { '<leader>g', group = '[G]it' },
        { '<leader>l', group = '[L]SP' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle/Tools' },
        { '<leader>r', group = 'Search and [R]eplace' },
        { '<leader>h', group = '[H]TTP Client' },

        -- Yank to system clipboard
        { '<leader>y', '"+y', desc = 'Yank to system clipboard', mode = { 'n', 'v' } },
        { '<leader>Y', '"+Y', desc = 'Yank line to system clipboard', mode = 'n' },

        -- Delete to system clipboard (cut)
        { '<leader>d', '"+d', desc = 'Delete to system clipboard', mode = { 'n', 'v' } },
        { '<leader>D', '"+D', desc = 'Delete to EOL to system clipboard', mode = 'n' },

        -- Paste from system clipboard
        { '<leader>p', '"+p', desc = 'Paste from system clipboard', mode = { 'n', 'v' } },
        { '<leader>P', '"+P', desc = 'Paste before from system clipboard', mode = { 'n', 'v' } },
      })
    end,
  },
  -- }}}

  -- {{{ UI
  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
    dependencies = {
      'MaximilianLloyd/ascii.nvim',
      'mahyarmirrashed/famous-quotes.nvim',
    },
    opts = {
      notifier = { enabled = true },
      lazygit = { enabled = true },
      indent = { enabled = true },
      bigfile = {},
      picker = {},
      statuscolumn = {},
      input = {},
      terminal = { enabled = true },
      dashboard = {
        formats = {
          key = function(item)
            return { { '[', hl = 'special' }, { item.key, hl = 'key' }, { ']', hl = 'special' } }
          end,
        },
        preset = {
          keys = {
            { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
            { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
            { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = ' ', key = 'c', desc = 'Config', action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
            { icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
            {
              icon = ' ',
              key = 'R',
              desc = 'Refresh dashboard',
              action = function()
                Snacks.dashboard.update()
              end,
            },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
        },
        sections = {
          -- Custom header. ascii.nvim stores these as array of lines, so need to render individualy
          function()
            local ascii = require('ascii')

            local art_choices = {
              ascii.art.text.neovim.sharp,
              ascii.art.text.neovim.dos_rebel,
              ascii.art.text.neovim.default1,
              ascii.art.text.neovim.isometric,
              ascii.art.text.neovim.ogre,
              ascii.art.text.neovim.ansi_shadow,
              ascii.art.text.neovim.bloody,
              ascii.art.text.neovim.elite,
              ascii.art.text.neovim.larry_3d,
            }

            local selected_art = art_choices[math.random(#art_choices)]
            local lines = { padding = 2, align = 'center' }

            for _, line in ipairs(selected_art) do
              table.insert(lines, { text = { line, hl = 'Title' } })
            end

            return lines
          end,
          { title = 'MRU ', file = vim.fn.fnamemodify('.', ':~'), padding = 1 },
          { section = 'recent_files', cwd = true, limit = 8, padding = 1 },

          { title = 'Bookmarks', padding = 1 },
          { section = 'keys' },

          { title = 'Quote', padding = { 1, 1 } },

          function()
            local quote = require('famous-quotes').get_quote()[1]
            local dash_width = 60

            local lines = break_sentence('«' .. quote.quote .. '»', dash_width)
            local items = { padding = 1 }

            for _, line in ipairs(lines) do
              table.insert(items, { text = { line, hl = 'String', align = 'left' } })
            end

            table.insert(items, { text = { ' — ' .. quote.author, hl = 'Comment', align = 'right' } })

            return items
          end,

          { section = 'startup', padding = { 1, 1 } },
        },
      },
    },
    keys = {
      {
        '<leader>gg',
        function()
          require('snacks').lazygit()
        end,
        desc = 'Lazy[G]it',
      },
    },
    init = function()
      vim.notify = function(msg, level, opts)
        require('snacks').notifier.notify(msg, level, opts)
      end
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        globalstatus = true,
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim', 'folke/trouble.nvim' },
    opts = {},
    keys = {
      { '<leader>td', '<cmd>TodoFzfLua<CR>', desc = 'To[D]os' },
    },
  },
  {
    'mahyarmirrashed/famous-quotes.nvim',
    opts = {},
  },
  {
    'romgrk/barbar.nvim',
    lazy = false,
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {},
    keys = {
      { '<S-h>', '<cmd>BufferPrevious<CR>', desc = 'Previous buffer' },
      { '<S-l>', '<cmd>BufferNext<CR>', desc = 'Next buffer' },
      { '<leader>bd', '<cmd>BufferClose<CR>', desc = '[D]elete' },
      { '<leader>bo', '<cmd>BufferCloseAllButCurrentOrPinned<CR>', desc = 'Close [O]thers' },
      { '<leader>bp', '<cmd>BufferPin<CR>', desc = '[P]in' },
    },
  },
  {
    'MaximilianLloyd/ascii.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
  },
  {
    'rachartier/tiny-code-action.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'ibhagwan/fzf-lua' },
    },
    event = 'LspAttach',
    keys = {
      {
        '<leader>ca',
        function()
          require('tiny-code-action').code_action()
        end,
        desc = '[A]ctions',
      },
    },
    opts = {},
  },
  -- }}}

  -- {{{ Edit history
  {
    'XXiaoA/atone.nvim',
    opts = {},
    keys = {
      { '<leader>tu', '<cmd>Atone<CR>', desc = '[U]ndo history' },
    },
  },
  -- }}}

  -- {{{ File manager
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'antosha417/nvim-lsp-file-operations',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons', -- optional, but recommended
    },
    lazy = false,
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'Open file manager' },
      { '<leader>be', '<cmd>Neotree buffers toggle<CR>', desc = '[E]xplore buffers' },
    },
    config = function()
      require('neo-tree').setup({
        filesystem = {
          follow_current_file = {
            enabled = true,
            leave_dirs_open = false,
          },
        },
      })

      vim.api.nvim_create_autocmd('TermClose', {
        pattern = '*lazygit',
        callback = function()
          require('neo-tree.events').fire_event('git_event')
        end,
      })
    end,
  },
  -- }}}

  -- {{{ Search
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    keys = {
      { '<leader><leader>', '<cmd>lua require("fzf-lua").files()<CR>', desc = 'Search files' },
      { '<leader>sg', '<cmd>lua require("fzf-lua").live_grep()<CR>', desc = 'Live [G]rep' },
      { '<leader>sw', '<cmd>lua require("fzf-lua").grep_cword()<CR>', desc = '[W]ord under cursor' },
      { '<leader>sv', '<cmd>lua require("fzf-lua").grep_visual()<CR>', desc = '[V]isual selection', mode = 'v' },
    },
  },
  {
    'MagicDuck/grug-far.nvim',
    opts = {},
    keys = {
      { '<leader>rr', '<cmd>lua require("grug-far").open({ transient = true })<CR>', desc = '[R]eplace' },
    },
  },
  -- }}}

  -- {{{ LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'saghen/blink.cmp',
      'folke/which-key.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
          end

          map('gd', '<cmd>FzfLua lsp_definitions<CR>', '[G]o to [D]efinition')
          map('gr', '<cmd>FzfLua lsp_references<CR>', '[G]o to [R]eferences')
          map('gi', '<cmd>FzfLua lsp_implementations<CR>', '[G]o to [I]mplementations')
          map('<leader>ls', '<cmd>FzfLua lsp_document_symbols<CR>', 'Document [S]ymbols')
          map('<leader>lx', '<cmd>FzfLua diagnostics_document<cr>', 'Diagnostics')
          map('<leader>lX', '<cmd>FzfLua diagnostics_workspace<cr>', 'Global Diagnostics')
          map('<leader>lq', '<cmd>FzfLua quickfix<cr>', '[Q]uickfix')
          map('<leader>lr', vim.lsp.buf.rename, '[R]ename')

          -- Inline diagnostics
          vim.diagnostic.config({
            virtual_text = {
              prefix = '● ', -- Could be '■', '▎', etc.
              spacing = 4,
            },
            underline = true,
            update_in_insert = false, -- Don't show while typing
            severity_sort = true,
            float = {
              border = 'rounded',
              source = 'always',
            },
          })
        end,
      })

      lsp_configs()
    end,
  },
  -- }}}

  -- {{{ Autocomplete & snippets
  { 'rafamadriz/friendly-snippets' },
  {
    dir = vim.g.blink_cmp_path,
    name = 'blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      completion = {
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
        },
        menu = {
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind' },
            },
          },
        },
      },
    },
  },
  -- }}}

  -- {{{ Formatter
  {
    'stevearc/conform.nvim',
    keys = {
      { '<leader>cf', '<cmd>lua require("conform").format()<CR>', desc = '[F]ormat' },
    },
    opts = {
      lsp_format = 'fallback',
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'biome' },
        typescript = { 'biome' },
        json = { 'biome' },
        typescriptreact = { 'biome' },
        svelte = { 'prettier' },
        astro = { 'prettier' },
        html = { 'prettier' },
        scss = { 'prettier' },
        css = { 'prettier' },
        jsx = { 'prettier' },
        tsx = { 'prettier' },
        yaml = { 'prettier' },
        rust = { 'rustfmt' },
        python = { 'black' },
        go = { 'gofumpt' },
        markdown = { 'mdformat' },
        toml = { 'taplo' },
        nix = { 'alejandra' },
      },
    },
  },
  -- }}}

  -- {{{ Git
  {
    'lewis6991/gitsigns.nvim',
    lazy = false,
    opts = {},
    keys = {
      { '<leader>gs', '<cmd>lua require("gitsigns").stage_hunk()<CR>', desc = '[S]tage hunk' },
      {
        '<leader>gs',
        '<cmd>lua require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })<CR>',
        mode = 'v',
        desc = '[S]tage selection',
      },

      { '<leader>gr', '<cmd>lua require("gitsigns").reset_hunk()<CR>', desc = '[R]eset hunk' },
      {
        '<leader>gr',
        '<cmd>lua require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })<CR>',
        mode = 'v',
        desc = '[R]eset selection',
      },

      { '<leader>gv', '<cmd>lua require("gitsigns").preview_hunk()<CR>', desc = 'Pre[V]iew hunk' },

      { '<leader>gb', '<cmd>lua require("gitsigns").blame_line({ full = true })<CR>', desc = '[B]lame line' },
    },
  },
  -- }}}
}

-- {{{ Lazy bootstrap
vim.opt.rtp:prepend(vim.g.lazy_path)

require('lazy').setup({
  install = { colorscheme = { 'habamax' } },
  checker = { enabled = false, notify = false },
  git = { timeout = 300 },
  spec = plugin,
})
-- }}}

-- }}}

-- {{{ Theme switcher
vim.cmd.colorscheme('catppuccin-mocha')
-- }}}

-- {{{ Tweaks

-- Clear highlight after search
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Keep visual on indent
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '<', '<gv')

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Godot server tweak
local cwd = vim.fn.getcwd()
local project_file = vim.fs.joinpath(cwd, 'project.godot')
local server_file = vim.fs.joinpath(cwd, 'server.pipe')

if vim.uv.fs_stat(project_file) and not vim.uv.fs_stat(server_file) then
  vim.fn.serverstart(server_file)
  print('Godot server started')
end
-- }}}
