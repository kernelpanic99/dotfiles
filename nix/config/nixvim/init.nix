{...}: {
  imports = [
    ./options.nix
    ./keymaps.nix
    ./lsp.nix
    ./plugins.nix
  ];

  enable = true;
  nixpkgs.config.allowUnfree = true;
  colorschemes.catppuccin.enable = true;
}
