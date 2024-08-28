disk = {
  filesystem = {
    type = "btrfs";
    options = "";
    subvolumes = [];
  };
  device = "/dev/nvme0n1";
  ssd = true;
};

disk.encryption = {
  enable = true;
  passkey = "";
};
