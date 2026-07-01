{...}: {
  imports = [
    ./llm.nix
    ./backup-schedule.nix
    ./llm-agents.nix
  ];

  networking.hostName = "desktop";

  services.xserver.videoDrivers = ["amdgpu"];
}
