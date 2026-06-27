{...}: {
  networking.hostName = "laptop";

  services.xserver.videoDrivers = ["nvidia" "amdgpu"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      amdgpuBusId = "PCI:5:00:0";
      nvidiaBusId = "PCI:1:00:0";
    };
  };
}
