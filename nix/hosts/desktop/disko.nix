{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S1000G_50026B7785946C11";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0022" "dmask=0022"];
              };
            };

            root = {
              size = "100%";
              content = {
                type = "luks";
                name = "main";
                settings = {
                  allowDiscards = true;
                };

                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };

      data = {
        device = "/dev/disk/by-id/nvme-KINGSTON_SNV3S2000G_50026B7687517ADA";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "data";
                settings = {
                  allowDiscards = true;
                };

                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/home/kp/data";
                };
              };
            };
          };
        };
      };
    };
  };
}
