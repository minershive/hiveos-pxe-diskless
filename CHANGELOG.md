#### 2021-12-28 Version 6.5
* Minor image fix
* Fix Opencl loader

#### 2021-12-17 Version 6.4
* synced with Hive client v0.6-212
* NEW Linux kernel 5.15
* Update AMD OpenCL libs and amdgpu firmwares to version 21.40.1
* Update NVIDIA drivers to version 470.86
* AMD OpenCL & NVIDIA drivers replaced to standalone archives (opencl-21.40.1.tar.xz & nvidia-470.86.tar.xz)
* Add two new boot options (opencl_version and nvidia_version)
    e.g. "opencl_version=opencl-21.40.1.tar.xz nvidia_version=nvidia-470.86.tar.xz", 
    in future releases will be added some others versions...


#### 2021-08-18 Minor fix
* Fix and update (0.6-208) hiveramfs image
* Add pxz (parallel LZMA compressor using liblzma) for fast multi thread compressing


#### 2021-08-13 Minor fix
* Minor fix

#### 2021-08-12 update kernel version
* Update kernel to 5.10.0-hiveos
* Update Nvidia driver to 465.24.02
* Update Amdgpu driver to latest
* Added amdgpu firmware for Radeon RX 6600 series (Navi23)
* Minor fixes

#### 2021-03-17 Replace some libs for RX 6X00
* Minor fixes

#### 2021-03-11 Fixed loading amdgpu driver
* Added some missing firmware
* Initial support OC for Nvidia cards (460.56 driver update)
* Added some info for WEB
* Minor fixes

#### 2021-03-04 Fixed loading amdgpu driver
* Updated kernel firmware to latest 
* Minor fixes
 
#### 2021-02-25 Migrating to Stable Image based on Ubuntu 18.04 LTS
Based on latest Hive Stable Image
* Linux kernel 5.4.99
* Linux amdgpu kernel module  with supports up to "Big Navi" GPU
* AMD OpenCL 20.40
* Nvidia support added (but not tested very well)

#### 2019-12-28 Fixes and FS update
* fixed image update script
* synced with Hive client v0.6-99

#### 2019-12-03 Fixes and improvements
* updated image update script
* fixed installation script
* minor fixes

#### 2019-11-23 Fixes
* updated image update script

#### 2019-10-12 Fixes and improvements
* changed apache to nginx
* changed PXE to iPXE
* changed nfs to http
* replace dnsmasq-tftp to atftpd
* update installation manual

#### 2019-07-23 Initial relase based on Stable Image (Ubuntu 16.04 LTS based)
