# Platinenmacher Linux Build System

This repository contains a highly opinionated Yocto/BitBake build system for [**TheBrutzler v2**](https://github.com/theBrutzler/BrutzelBoy_V2), an embedded board built with the Rockchip RK3566 SoC.
The build system generates custom Linux images for the hardware platform.

## Overview

**Build System**: Yocto Project (Whinlatter release)
**Distro**: Platinenmacher Linux (based on poky)

## Repository Structure

```
pm-build/
├── bitbake/                       # BitBake build tool
├── bitbake-builds/                # Build configurations and output
│   └── poky-whinlatter/           # Poky distribution build
│       ├── build/                 # Build directory
│       ├── buildtools/            # SDK and build tools
│       └── layers/                # Upstream Yocto layers
│           ├── meta-arm/          # https://git.yoctoproject.org/meta-arm
│           ├── meta-openembedded/ # https://git.openembedded.org/meta-openembedded
│           ├── meta-rockchip/     # https://git.yoctoproject.org/meta-rockchip
│           ├── meta-swupdate/     # https://github.com/sbabic/meta-swupdate
│           ├── meta-yocto/        # https://git.yoctoproject.org/meta-yocto
│           └── openembedded-core/ # https://git.openembedded.org/openembedded-core
├── meta-platinenmacher/           # Common Platinenmacher layer
│   └── conf/                      # Board and layer configuration
│       └── distro/                # Distro definitions
│           └── platinenmacher-linux.conf
├── meta-pm-thebrutzler/           # TheBrutzler v2 specific layer
│   └── conf/                      # Board and layer configuration
│       └── machine/               # Machine definitions
│           └── thebrutzler_v2.conf
└── init-build-env                 # Environment setup script
```

## Prerequisites

### Host System Requirements
- Ubuntu 22.04 (or compatible Linux distribution)
- At least 50GB free disk space
- 8GB RAM minimum (16GB recommended)

## Available Images

### brutzelboy
An image for the brutzelboy during development with A/B partition layout for OTA updates.

**Features:**
- A/B rootfs partitions (rootfsA and rootfsB) for safe updates
- Dynamic partition sizing (2GB per rootfs partition)
- Persistent userdata partition mounted at /home
- First-boot automatic expansion of userdata to use remaining disk space
- Configuration persistence across updates (SSH keys, network settings, etc.)
- Pre-configured thebrutzler user (UID 1000) with passwordless sudo
- OpenSSH server for remote access
- SWUpdate integration for reliable OTA updates

### brutzelboy-swupdate-full
Full SWUpdate package (.swu) containing rootfs AND bootloader components with version checking.

**Features:**
- **Cryptographically signed** with RSA-4096 for security
- Includes rootfs, idbloader.img, and u-boot.itb
- Conditional bootloader updates (only if version is newer)
- Version tracking via /etc/bootloader-version and U-Boot environment
- Safer than manual bootloader flashing
- Signature verified on device before installation

**Build:**
```bash
bitbake brutzelboy-swupdate-full
```

**When to use:**
- Use `brutzelboy-swupdate` for regular rootfs updates (safer, faster)
- Use `brutzelboy-swupdate-full` when bootloader updates are needed

**Note:** The Lua hook `check_bootloader_version` compares versions before updating bootloader components.

## Update Security

All SWUpdate packages are **cryptographically signed** using RSA-4096 to ensure authenticity and integrity.

### Development vs Production Keys

**⚠️ Important**: The repository includes a **development key** for testing purposes only.

See [System Updates](Documentation/system-updates.md)

## System Users

### thebrutzler (UID 1000)
Pre-configured user account for system access:

**Login:**
- **Serial Console**: No password required (just press Enter at prompt)
- **SSH**: Set up SSH keys in /home/thebrutzler/.ssh/

**Permissions:**
- Passwordless sudo access (member of sudo, wheel groups)
- Member of audio, video groups for hardware access
- Home directory: /home/thebrutzler (persistent across updates)

**Shell**: /bin/bash

### root
Root account for system administration:
- **No password set by default ⚠️**
- Direct serial console login available
- Use `sudo` from thebrutzler account for daily operations

## Meta Layers

### meta-pm-thebrutzler
TheBrutzler v2 hardware-specific layer containing:
- **Machine Configuration**: RK3566/RK3568 board definitions
- **Kernel**: Linux kernel recipes and device trees
- **BSP**: Rockchip binary packages (rkbin)
- **Utilities**: Flash tools and board-specific scripts

**Dependencies:**
- meta (OpenEmbedded Core)
- meta-arm
- meta-rockchip

### meta-platinenmacher
Common Platinenmacher layer with:
- **Image recipes**: Standard image definitions with A/B update support
- **Package groups**: Curated software collections
- **Update system**: SWUpdate integration with A/B rootfs partitioning
- **Bootloader updates**: Conditional bootloader updates with version tracking
- **WKS files**: Custom partitioning layouts (platinenmacher-ab.wks)
- **System services**:
  - First-boot userdata partition resize (resize-userdata.service)
  - Configuration persistence (persist-config.service, restore-config.service)
  - Bootloader version sync (swupdate-bootenv.service)
  - Systemd mount unit for /home
- **User management**: Pre-configured thebrutzler user with passwordless sudo

## Build Configuration

### Machine: thebrutzler_v2
- **Architecture**: ARM64 (aarch64)
- **SoC Family**: Rockchip RK3566/RK3568
- **Kernel**: linux-yocto-dev
- **U-Boot**: `lckfb-tspi-rk3566_defconfig`
- **Device Tree**: `meta-pm-thebrutzler/recipes-kernel/linux/files/lcsc-taishanpi-rk3566.dts`
- **Kernel Image**: FIT image with artifacts

### Layer Compatibility
- **Yocto Release**: Whinlatter

## Common Tasks

### Build brutzelboy
```bash
./build.sh brutzelboy
```

### Build Update Packages
```bash
bitbake brutzelboy-swupdate-full
```
The .swu files will be in `tmp/deploy/images/thebrutzler_v2/`

### Build SDK
```bash
./build.sh brutzelboy -c populate_sdk
```

### List Available Images
```bash
./build.sh list
```

## Utilities

### flash-bmap
Located in `meta-pm-thebrutzler/bin/`, this script simplifies flashing images using bmaptool:
```bash
flash-bmap <image.wic> <device>
```

### SWUpdate
The system includes SWUpdate for A/B updates:

**Web Interface**: http://device-ip:8080

**Command Line Update**:
```bash
# Full update with bootloader
swupdate -i brutzelboy-swupdate-full-thebrutzler_v2.swu
```

**Configuration Persistence:**
- System configuration automatically saved before shutdown/reboot
- Settings restored after updates complete
- User data in /home persists across all updates
- No manual backup needed for SSH keys or network settings

**First Boot**: The userdata partition at /home will automatically expand to use all available disk space:
- Waits for udev to settle and partition labels to appear
- Fixes GPT backup header location
- Resizes partition to 100% of available space
- Expands ext4 filesystem to match
- Creates marker file to prevent re-running

## Pre-commit Hooks

This project uses [pre-commit](https://pre-commit.com/). Pre-commit hooks automatically check your changes before committing.

### Installation

```bash
# Install pre-commit
pip install pre-commit

# Install the git hook scripts
pre-commit install
```

### Usage

Once installed, pre-commit will automatically run on `git commit`. To manually run all hooks on all files:

```bash
pre-commit run --all-files
```

### Configured Hooks

- **Trailing whitespace**: Removes trailing whitespace
- **End of file fixer**: Ensures files end with a newline
- **YAML/JSON syntax**: Validates configuration files
- **Mixed line endings**: Normalizes line endings
- **Large files check**: Prevents committing large files
- **Merge conflict markers**: Detects unresolved merge conflicts

## Contributing

When contributing to this project:
1. Follow Yocto Project conventions
2. Test builds before submitting
3. Update documentation for new features
4. Keep layers modular and focused

## Resources

- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [BitBake User Manual](https://docs.yoctoproject.org/bitbake/)

## License

See individual layer COPYING.MIT files for license information.
