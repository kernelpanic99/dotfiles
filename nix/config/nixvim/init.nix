{...}: {
  imports = [
    ./options.nix
    ./keymaps.nix
    ./lsp.nix
    ./plugins.nix
  ];

  enable = true;
  defaultEditor = true;
  nixpkgs.config.allowUnfree = true;
  colorschemes.catppuccin.enable = true;
}
