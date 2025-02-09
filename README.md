# Hive OS PXE Diskless
Network boot for diskless rigs

Documentation
https://forum.hiveos.farm/t/hive-os-diskless-pxe/12319

Requires : sudo, xz-utils, pxz
```apt-get install -yqq sudo xz-utils pxz```

For installation directly from the GitHub, execute the following command in the terminal:

```wget https://raw.githubusercontent.com/minershive/hiveos-pxe-diskless/master/pxe-setup.sh && sudo bash pxe-setup.sh```

```cd  path_to_pxeserver```

Type ```./deploy_pxe ubuntu20 --build```.
This command create new hiveramfs image in pxeserver/hiveramfs/ folder. Rootfs stored in pxeserver/build/ubuntu20/_fs.
Ubuntu 20.04 set as default, but you can use ubuntu18|ubuntu20|ubuntu22 option for build custom image.
Set default boot image in  pxeserver/tftp/efi/default.cfg
Try ```./deploy_pxe --help``` for see more options

## Create custom boot config
You can manually create custom boot config for PXE UEFI to boot different images on different PXE RIGS
Just copy pxeserver/tftp/efi/default.cfg to pxeserver/tftp/efi/custom/aa:bb:cc:dd:ee:ff.cfg (where aa:bb:cc:dd:ee:ff is a mac-address of your rig).
You can change in them ram_size for image, image_name, AMD OpenCL or Nvidia driver version.

If you need support Nvidia cards, use ```./deploy_pxe nvidia list``` for list all avaliable drivers and ```./deploy_pxe nvidia --build <VER>``` to create nvidia-<VER>.tar.xz image.
This image will be stored in pxeserver/hiveramfs/nvidia folder.

**After version 6.5.3  full support ONLY UEFI PXE boot.** 
**Legacy PXE boot is DEPRECATED and work not guaranteed. You can edit Legacy PXE config manualy.**
