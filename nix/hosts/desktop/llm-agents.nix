# Example of wiring a host-specific flake input.
#
# AI coding-agent CLIs from github:numtide/llm-agents.nix, installed on the
# desktop only. `inputs` reaches this module via the flake's specialArgs; the
# laptop never imports this file, so the llm-agents input stays unused there.
{
  pkgs,
  inputs,
  ...
}: {
  nix.settings = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };

  environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    opencode
  ];
}
