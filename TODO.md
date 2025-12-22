# Bringup log of Thebrutzler V2 PCB

## General functions
- [x] Update motd
- [x] Create fitImage

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
  - [ ] No Signals -> Maybe needs an antenna?
- [x] Bluetooth-Module (&uart1)
- [ ] HDMI
  - [x] Connector
  - [x] Supplies
  - [x] Endpoints
  - [ ] HPD -> Does not work!
  - [x] CEC
  - [ ] DDC
  - [ ] Sound
- [x] GPU
- USB
  - [ ] OTG (USB-C) -> Doesn't boot when connected to USB-C Port of PC
  - [x] Host1 (USB3.0 MB Connector)
  - [x] Host2 (USB-A)
- [ ] MIPI DSI
- [ ] eDP
- LED
  - [x] Heartbeat
- Buttons
  - [ ] Reset -> Does not work!
  - [x] SARADC Ch0 -> Pressed < 20 not pressed 1023
  - [ ] Power On
- Camera
  - [ ] MIPI CSI
  - [ ] Regulator VCC2V8
  - [ ] Regulator VCC1V8
  - [ ] Regulator VCC1V2
- Audio
  - [x] RK809 in
  - [x] RK809 out

## Partition schema
- [x] add secondary rootfs partition
- [x] create swupdate sw-description file
- [x] create resize-userdata service for persistent /home
- [ ] provide swupdate server

## User
- [x] Add user thebrutzler

## GH Release
- [x] upload an image to Github Release
