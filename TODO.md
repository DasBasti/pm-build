# Bringup log of Thebrutzler V2 PCB

## General functions
- [x] Update motd
- [x] Create fitImage
- [ ] Limit access to u-boot environment
- [ ] Run fsck automatically during boot
- [ ] Setup global keys recipe in meta-platinenmacher for
  - [ ] Rootca and derived keys for
  - [ ] fitImages
  - [ ] swupdate
  - [ ] Secureboot

## Devicetree nodes
- [x] Add dedicated device tree for PCB
- Power Regulators
  - [x] vcc12v0_dcin -> Not connectable!
  - [x] vcc5v0_sys (From USB-C connector)
  - [x] vcc3v3_sys (From vcc5v0_sys)
  - [x] vcc5v0_host (Enable with GPIO4_C4, overridden with R78)
  - [x] sdio_pwrseq (WIFI_REG_ON_H)
- [x] I2C0
  - [x] PMIC RK809 (0x20)
    - [x] Regulator
    - [x] Sound
  - [x] TCS4525 (0x1c)
- [x] I2C1
- [x] I2C4
- [x] I2C6 (HDMI DDC)
- [x] Serial console UART2
- [x] SD-Card (&mmc0 = &sdmmc0)
- [ ] eMMC (&mmc1 = &sdhci init failed)
- [x] WiFi-Module (&mmc2 = &sdmmc1)
  - [x] Scan Signals
  - [x] connman
  - [x] working connection
  - [x] wpa_supplicant needs to be removed
  - [ ] initial tethering for setup
- [x] Bluetooth-Module (&uart1)
- [ ] HDMI
  - [x] Connector
  - [x] Supplies
  - [x] Endpoints
  - [x] HPD -> Remove Diodes on Data lines (wrong polarity)
  - [x] CEC
  - [x] DDC
  - [ ] Sound
  - [ ] Parsing error in devicetree asoc-simple-card
- [x] GPU
- USB
  - [x] OTG
  - [x] Host1 (USB3.0 MB Connector)
  - [x] Host2 (USB-A)
- [ ] MIPI DSI
- [ ] eDP
- LED
  - [x] Heartbeat
- Buttons
  - [x] Reset -> Wire R117 -> C34 to connect reset circuits
  - [x] SARADC Ch0 -> Pressed < 20 not pressed 1023
  - [x] Power On
- Camera
  - [ ] MIPI CSI
  - [ ] Regulator VCC2V8
  - [ ] Regulator VCC1V8
  - [ ] Regulator VCC1V2
- Audio
  - [x] RK809 in
  - [x] RK809 out

## Updates
- [x] add secondary rootfs partition
- [x] create swupdate sw-description file
- [x] create resize-userdata service for persistent /home
- [ ] provide swupdate server
- [X] make swu installable
  - [x] make u-boot use the environment partition
  - [x] modifyable u-boot environment from userspace
  - [X] Board, type and copy are detected
- [x] New A/B-Boot mechanism
  - [x] Create a single boot partition size it to easily fit two kernels (in-progress: FAT 512M)
  - [x] Build fitImage with kernel and devicetree. (in-progress)
  - [x] Deploy the fitImage instead of kernel and devicetree to the boot partition (installed as `fitImage-A` / `fitImage-B` via image postprocessing)
  - [x] Deploy extlinux.conf to the boot partition (extlinux.conf now contains `A`/`B` labels; default = A)
  - [x] Have uboot boot fitImage A or B from the boot partition (extlinux labels created)
  - [x] update swupdate sw-descriptions to support switching to the image that got target. (in-progress)
- [ ] Updates work
  - [ ] a/b image mechanism works as expected. bootflow cannot see mmcblk0p10 as boot target even with image on it
  - [ ] test full update file
  - [ ] use links in fullupdate file to have only one bootloader block
  - [ ] think about location for copy version detection for A/B image (info should be part of bsp, script part of distro)
  - [ ] restart after update does not work as expected
- [ ] Rescue to start once we hit 3 failed start attempts and fallback did not work
  - [ ] include rescue in initramfs-image
  - [ ] ship initramfs-image for rescue as artifact in regualar image
  - [ ] update if rescue image changed (newer image was successfully booted)

## Housekeeping
- [ ] sort out swupdate recipe splits in meta-platinenmacher and meta-pm-thebrutzler
- [ ] rename brutzelboy to pmlinux
- [ ] validat that dtb and initramfs is loaded from fitImage

## Config persistence
- [ ] Check save of config on reboot
- [ ] remove wpa_supplicant form config list

## User
- [x] Add user thebrutzler
- [ ] Sudo not working for thebrutzler user

## GH Release
- [x] upload an image to Github Release
