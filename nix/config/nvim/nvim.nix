{pkgs, ...}: {
  enable = true;
  defaultEditor = true;

  extraPackages = with pkgs; [
    # LSP servers
    vtsls
    biome
    vscode-langservers-extracted # cssls, htmlls, jsonls, eslintls
    tailwindcss-language-server
    astro-language-server
    svelte-language-server
    rust-analyzer
    gopls
    marksman
    yaml-language-server
    terraform-ls
    lua-language-server
    dockerfile-language-server
    bash-language-server
    fish-lsp
    pyright
    zls
    docker-compose-language-service
    tombi
    luau-lsp
    # Formatters
    stylua
    prettier
    black
    mdformat
    taplo
    nixd
  ];

  initLua =
    ''
      vim.g.lazy_path = "${pkgs.vimPlugins.lazy-nvim}"
      vim.g.treesitter_path = "${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}"
      vim.g.blink_cmp_path = "${pkgs.vimPlugins.blink-cmp}"
    ''
    + builtins.readFile ./init.lua;
}
