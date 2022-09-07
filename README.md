# Hive OS PXE Diskless
Network boot for diskless rigs

Documentation
https://forum.hiveos.farm/t/hive-os-diskless-pxe/12319

Requires : sudo, xz-utils, pxz
```apt-get install -yqq sudo xz-utils pxz```

For installation directly from the GitHub, execute the following command in the terminal:

```wget https://raw.githubusercontent.com/minershive/hiveos-pxe-diskless/master/pxe-setup.sh && sudo bash pxe-setup.sh```

```cd  path_to_pxeserver```

Type ```./deploy_pxe ubunru18 --create```.
This command create new hiveramfs image in pxeserver/hiveramfs/ folder. Rootfs stored in pxeserver/build/ubuntu18/_fs.
Try ```./deploy_pxe --help``` for see more options

If you need support Nvidia cards, use ```./deploy_pxe nvidia list``` for list all avaliable drivers and ```./deploy_pxe nvidia --build <VER>``` to create nvidia-<VER>.tar.xz image.
This image will be stored in pxeserver/hiveramfs/nvidia folder.

**Below part deprecated and will be removed in next release!!!**
**Important note:** the file system archive is splitting into several files. Due to github restrictions on file size.
In case you clone or download this repository yourself - you need to collect parts of the archive back into one file:

```cat pxeserver/hiveramfs/x* > pxeserver/hiveramfs/hiveramfs.tar.xz```
