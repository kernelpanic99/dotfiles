{...}: {
  networking.hostName = "desktop";

  services.xserver.videoDrivers = ["amdgpu"];
}
