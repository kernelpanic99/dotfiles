{
  "$schema" = "https://charm.land/crush.json";
  models = {};
  providers = {};
  mcp = {};
  lsp = {
    typescript = {
      command = "vtsls";
      args = ["--stdio"];
    };
    rust = {
      command = "rust-analyzer";
    };
    nix = {
      command = "nixd";
    };
  };
  hooks = {};
  options = {};
  permissions = {};
  tools = {};
}

