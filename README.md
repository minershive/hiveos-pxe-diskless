# Hive OS PXE Diskless
Network boot for diskless rigs

Documentation
https://forum.hiveos.farm/t/hive-os-diskless-pxe/12319

Requires : sudo, xz-utils, pxz
```apt-get install -yqq sudo xz-utils pxz```

For installation directly from the GitHub, execute the following command in the terminal:

```wget https://raw.githubusercontent.com/minershive/hiveos-pxe-diskless/master/pxe-setup.sh && sudo bash pxe-setup.sh```



**Important note:** the file system archive is splitting into several files. Due to github restrictions on file size.
In case you clone or download this repository yourself - you need to collect parts of the archive back into one file:

```cat pxeserver/hiveramfs/x* > pxeserver/hiveramfs/hiveramfs.tar.xz```
