-- vim: foldmethod=marker shiftwidth=2
-- zo - open section, zc - close section, zR - open all, zM - close all

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

local ts_path = vim.fn.stdpath('data') .. '/site'
vim.opt.runtimepath:prepend(ts_path)
-- }}}

-- {{{ Check executables
local executables = { 'rg', 'lazygit', 'fzf', 'fd', 'git', 'cargo +nightly', 'tmux' }
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
local ts_parsers = {
  'fish',
  'bash',
  'javascript',
  'typescript',
  'terraform',
  'json',
  'html',
  'astro',
  'svelte',
  'tsx',
  'css',
  'scss',
  'yaml',
  'go',
  'rust',
  'toml',
  'ini',
  'hyprlang',
  'elixir',
  'erlang',
  'python',
  'query',
  'lua',
  'vim',
  'vimdoc',
  'c',
  'cpp',
  'http',
  'zig',
  'ron',
  'ecma',
}

local tools = {
  'vtsls',
  'biome',
  'cssls',
  'tailwindcss',
  'astro',
  'svelte',
  'stylelint_lsp',
  'rust_analyzer',
  'gopls',
  'lexical',
  'marksman',
  'yamlls',
  'terraformls',
  'lua_ls',
  'dockerls',
  'docker_compose_language_service',
  'bashls',
  'fish_lsp',
  'pyright',
  'stylua',
  'prettier',
  'black',
  'rustfmt',
  'mdformat',
  'taplo',
  'zls',
}

vim.filetype.add({
  extension = {
    ['http'] = 'http',
  },
})

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
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-tree.lua',
    },
    opts = {},
  },
  {
    'nvim-treesitter/nvim-treesitter', -- syntax parser for features like highliting, indents, folds, etc...
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      local ts = require('nvim-treesitter')

      ts.install(ts_parsers)

      ts.setup({
        install_dir = ts_path,
        highlight = { enable = true },
      })

      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
  {
    'folke/snacks.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      notifier = { enabled = true },
      lazygit = { enabled = true },
      explorer = { enabled = true },
    },
    keys = {
      {
        '<leader>gg',
        function()
          require('snacks').lazygit()
        end,
        desc = 'Lazy[G]it',
      },
      {
        '<leader>e',
        function()
          require('snacks').explorer()
        end,
        desc = 'Open file [E]xplorer',
      },
    },
    init = function()
      vim.notify = function(msg, level, opts)
        require('snacks').notifier.notify(msg, level, opts)
      end
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
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = false,
    enabled = false,
    config = function()
      local harpoon = require('harpoon')
      local wk = require('which-key')

      harpoon:setup()

      wk.add({
        { '<leader>h', nil, desc = '[H]arpoon' },
        {
          '<leader>hu',
          function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
          end,
          desc = 'Open [H]arpoon [U]I',
        },
        {
          '<leader>ha',
          function()
            harpoon:list():add()
          end,
          desc = '[H]arpoon [A]dd file',
        },
        {
          '<C-y>',
          function()
            harpoon:list():select(1)
          end,
          desc = 'Harpoon 1',
        },
        {
          '<C-u>',
          function()
            harpoon:list():select(2)
          end,
          desc = 'Harpoon 2',
        },
        {
          '<C-i>',
          function()
            harpoon:list():select(3)
          end,
          desc = 'Harpoon 3',
        },
        {
          '<C-o>',
          function()
            harpoon:list():select(4)
          end,
          desc = 'Harpoon 4',
        },
        {
          '<C-p>',
          function()
            harpoon:list():select(5)
          end,
          desc = 'Harpoon 5',
        },
      })
    end,
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
      { '<leader>td', '<cmd>TodoTrouble<CR>', desc = 'To[D]os' },
    },
  },
  {
    'folke/trouble.nvim',
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = 'Trouble',
    keys = {},
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
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local startify = require('alpha.themes.startify')
      local ascii = require('ascii')
      local quotes = require('famous-quotes')

      local selected = {
        ascii.art.planets.planets.saturn_plus,
        ascii.art.text.neovim.ogre,
        ascii.art.text.neovim.dos_rebel,
        ascii.art.text.neovim.ansi_shadow,
        ascii.art.text.neovim.elite,
        ascii.art.text.neovim.bloody,
        ascii.art.text.neovim.default1,
        ascii.art.text.neovim.sharp,
        ascii.art.misc.hydra.hydra,
        ascii.art.text.slogons.arch_btw_doom,
      }

      startify.section.header.val = function()
        return selected[math.random(#selected)]
      end

      local function make_quote_section()
        local quote = quotes.get_quote()[1]

        return {
          { type = 'padding', val = 2 },
          {
            type = 'group',
            val = {
              { type = 'text', val = 'Quote', opts = { hl = 'Special' } },
              { type = 'padding', val = 1 },
              { type = 'text', val = '«' .. quote.quote .. '»', opts = { hl = 'String' } },
              { type = 'text', val = '— ' .. quote.author, opts = { hl = 'Comment' } },
              { type = 'padding', val = 1 },
              startify.button('r', '󰑓 Refresh', '<cmd>AlphaRedraw<CR>'),
            },
          },
        }
      end

      startify.section.footer.val = make_quote_section

      startify.section.mru.val = { { type = 'padding', val = 0 } }

      startify.file_icons.provider = 'devicons'

      require('alpha').setup(startify.config)
    end,
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
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'saghen/blink.cmp',
      'folke/which-key.nvim',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function()
          local wk = require('which-key')

          wk.add({
            { 'gd', '<cmd>Trouble lsp_definitions<CR>', desc = '[G]o to [D]efinition' },
            { 'gr', '<cmd>Trouble lsp_references<CR>', desc = '[G]o to [R]eferences' },
            { 'gi', '<cmd>Trouble lsp_implementations<CR>', desc = '[G]o to [I]mplementations' },
            { '<leader>ls', '<cmd>Trouble lsp_document_symbols<CR>', desc = 'Document [S]ymbols' },
            { '<leader>lx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics' },
            { '<leader>lq', '<cmd>Trouble quickfix<cr>', desc = '[Q]uickfix' },
            { '<leader>lr', vim.lsp.buf.rename, desc = '[R]ename' },
          })

          lsp_configs()

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
    end,
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = { 'mason-org/mason.nvim', 'neovim/nvim-lspconfig' },
    opts = {},
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',
      'mason-org/mason-lspconfig.nvim',
    },
    opts = {
      ensure_installed = tools,
      integrations = {
        ['mason-lspconfig'] = true,
      },
    },
  },
  -- }}}

  -- {{{ Autocomplete & snippets
  { 'rafamadriz/friendly-snippets' },
  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
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
    build = 'cargo +nightly build --release',
  },
  -- }}}

  -- {{{ Formatter
  {
    'stevearc/conform.nvim',
    keys = {
      { '<leader>cf', '<cmd>lua require("conform").format()<CR>', desc = '[F]ormat' },
    },
    opts = {
      default_format_opts = {
        lsp_format = 'prefer',
      },
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

  -- {{{ AI
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {
      diff_opts = {
        auto_close_on_accept = true,
        open_in_current_tab = true,
        vertical_split = true,
        keep_terminal_focus = true,
      },
      terminal = {
        provider = 'snacks',
        split_side = 'right',
        split_width_percentage = 0.4,
      },
    },
    keys = {
      { '<leader>a', nil, desc = '[A]I/Claude Code' },
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle [C]laude, Alternate - <C-a>' },
      { '<C-a>', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude', mode = { 'n', 't' } },
      { '<C-a>', '<cmd>ClaudeCodeSend<cr>', desc = 'Open Claude with current selection', mode = 'v' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      {
        '<leader>as',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
      },
      -- Diff management
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },
  {
    'supermaven-inc/supermaven-nvim',
    build = function()
      pcall(require('supermaven-nvim.api').use_free_version())
    end,
    config = function()
      require('supermaven-nvim').setup({})
    end,
  },
  -- }}}

  -- {{{ HTTP client
  {
    'heilgar/nvim-http-client',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    event = 'VeryLazy',
    ft = { 'http', 'rest' },
    config = function()
      require('http_client').setup({
        -- Default keybindings (can be customized)
        keybindings = {
          select_env_file = '<leader>hf',
          set_env = '<leader>he',
          run_request = '<leader>hr',
          stop_request = '<leader>hx',
          toggle_verbose = '<leader>hv',
          toggle_profiling = '<leader>hp',
          dry_run = '<leader>hd',
          copy_curl = '<leader>hc',
          save_response = '<leader>hs',
          set_project_root = '<leader>hg',
          get_project_root = '<leader>hgg',
        },
      })
    end,
  },
  -- }}}
}

-- {{{ Lazy bootstrap
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=main', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  install = { colorscheme = { 'habamax' } },
  checker = { enabled = true },
  git = { timeout = 300 },
  spec = plugin,
})
-- }}}

-- }}}

-- {{{ Theme switcher
vim.cmd.colorscheme('catppuccin')
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

-- }}}
