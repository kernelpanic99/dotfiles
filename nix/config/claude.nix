{pkgs}: {
  enable = true;
  enableMcpIntegration = false;

  settings = {
    attribution = {
      commit = "";
      pr = "";
      sessionUrl = false;
    };
    tui = "fullscreen";
    theme = "dark";
    model = "opus";
  };

  lspServers = {
    go = {
      command = "${pkgs.gopls}/bin/gopls";
      args = ["serve"];
      extensionToLanguage = {
        ".go" = "go";
      };
    };

    typescript = {
      command = "${pkgs.vtsls}/bin/vtsls";
      args = ["--stdio"];
      extensionToLanguage = {
        ".ts" = "typescript";
        ".tsx" = "typescriptreact";
        ".mts" = "typescript";
        ".cts" = "typescript";
        ".js" = "javascript";
        ".jsx" = "javascriptreact";
        ".mjs" = "javascript";
        ".cjs" = "javascript";
      };
    };

    rust = {
      command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
      extensionToLanguage = {
        ".rs" = "rust";
      };
    };
  };

  rules = {
    general = ''
      - no em-dashes
    '';
    code-style = ''
      - no naked block statements: even single line block statements should have braces
      - vertical spacing: separate different kind of statements and blocks with empty lines
      - comments: do not comment unecessarily if the context is obvious from the code.
    '';
    documentation-style = ''
      - Documents describe the final approach only. State what IS, in the
        affirmative.
      - Never include contrastive/corrective framing ("as opposed to...",
        "instead of...", "rather than the earlier...", "note that we are NOT...").
      - Corrections I make in chat are context for you, not content for the
        doc. Do not memorialize the decision path or rejected alternatives
        unless I explicitly ask for a "rationale" or "alternatives considered"
        section.
    '';
  };
}
