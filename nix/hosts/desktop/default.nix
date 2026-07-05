{...}: {
  imports = [
    ./disko.nix
    ./llm.nix
    ./backup-schedule.nix
  ];

  networking.hostName = "desktop";

  services.xserver.videoDrivers = ["amdgpu"];
}
