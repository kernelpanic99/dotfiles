local parsers = {
  "bash",
  "css",
  "diff",
  "dockerfile",
  "fish",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")
    ts.setup()

    local have = {}
    for _, p in ipairs(ts.get_installed()) do
      have[p] = true
    end
    local missing = vim.tbl_filter(function(p)
      return not have[p]
    end, parsers)
    if #missing > 0 then
      ts.install(missing)
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
          return
        end
        if pcall(vim.treesitter.language.add, lang) then
          pcall(vim.treesitter.start, ev.buf, lang)
        end
      end,
    })
  end,
}
