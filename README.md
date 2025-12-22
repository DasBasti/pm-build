# Platinenmacher Linux Build System

This repository contains the Yocto/BitBake build system for [**TheBrutzler v2**](https://github.com/theBrutzler/BrutzelBoy_V2), an embedded board built with the Rockchip RK3566 SoC.
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

### Required Packages
```bash
sudo apt-get install -y \
    build-essential chrpath cpio debianutils diffstat file gawk gcc \
    git iputils-ping libacl1 locales python3 python3-git python3-jinja2 \
    python3-pexpect python3-pip python3-subunit python3-venv \
    python-is-python3 socat texinfo unzip wget xz-utils zstd
```

## Quick Start

### 1. Initialize the Build Environment
```bash
source init-build-env
```

This script will:
- Set up the BitBake environment
- Configure buildtools SDK
- Add TheBrutzler utility scripts to PATH

### 2. Configure the Build
The build is pre-configured for TheBrutzler v2 in:
- **Machine config**: `meta-pm-thebrutzler/conf/machine/thebrutzler_v2.conf`
- **Layer config**: `bitbake-builds/poky-whinlatter/build/conf/bblayers.conf`
- **Local config**: `bitbake-builds/poky-whinlatter/build/conf/local.conf`

### 3. Build an Image
```bash
# Build the minimal benchmark image
bitbake brutzelboy

# Or build a custom image
bitbake <your-image-name>
```

### 4. Flash the Image
After a successful build, flash the image to an SD card:
```bash
# You need to manually install bmaptool **once**
bitbake bmaptool-native -caddto_recipe_sysroot

# Using the provided flash-bmap utility
flash-bmap <path-to-wic-file> /dev/sdX
```

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

### brutzelboy-swupdate
SWUpdate package (.swu) containing the rootfs image for A/B updates (rootfs only).

**Build:**
```bash
bitbake brutzelboy-swupdate
```

**Deploy:**
The generated .swu file can be deployed via SWUpdate's web interface (port 8080) or command line.

### brutzelboy-swupdate-full
Full SWUpdate package (.swu) containing rootfs AND bootloader components with intelligent version checking.

**Features:**
- Includes rootfs, idbloader.img, and u-boot.itb
- Conditional bootloader updates (only if version is newer)
- Version tracking via /etc/bootloader-version and U-Boot environment
- Safer than manual bootloader flashing

**Build:**
```bash
bitbake brutzelboy-swupdate-full
```

**When to use:**
- Use `brutzelboy-swupdate` for regular rootfs updates (safer, faster)
- Use `brutzelboy-swupdate-full` when bootloader updates are needed

**Note:** The Lua hook `check_bootloader_version` compares versions before updating bootloader components.

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
- No password set by default
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
- **Benchmark recipes**: Performance testing tools
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
- **Device Tree**: `meta-pm-thebrutzler/recipes-kenel/linux/files/lcsc-taishanpi-rk3566.dts`
- **Kernel Image**: FIT image with artifacts

### Layer Compatibility
- **Yocto Release**: Whinlatter

## Development Workflow

### Adding New Recipes
1. Create recipe in appropriate layer under `recipes-*/`
2. Follow Yocto naming conventions: `<name>_<version>.bb`
3. Add to `IMAGE_INSTALL` in image recipe if needed

### Modifying Kernel
Kernel recipes are located in `meta-pm-thebrutzler/recipes-kenel/linux/`
```bash
# After modifying kernel config
bitbake virtual/kernel -c menuconfig
bitbake virtual/kernel -c savedefconfig
```

### Updating Device Tree
Device tree files are located in `meta-pm-thebrutzler/recipes-kenel/linux/files/lcsc-taishanpi-rk3566.dts` and set in machine config:
```bash
KERNEL_DEVICETREE = "rockchip/lcsc-taishanpi-rk3566.dtb"
```

## Partition Layout

The system uses an A/B partition scheme for safe OTA updates:

```
/dev/mmcblk0p1-8  : Bootloader partitions (loader1, v_storage, reserved, etc.)
/dev/mmcblk0p9    : rootfsA (active root filesystem, 2GB)
/dev/mmcblk0p10   : rootfsB (inactive root filesystem for updates, 2GB)
/dev/mmcblk0p11   : userdata (mounted at /home, expands to fill remaining space)
```

**Key Features:**
- **Fixed Root Size**: Each root partition is 2GB for predictable updates
- **Persistent Storage**: /home is on a separate partition that survives updates
- **Configuration Persistence**: System settings saved to /home/.system-config/
- **First Boot Resize**: userdata partition automatically expands on first boot using:
  - Partition label detection (/dev/disk/by-partlabel/userdata)
  - GPT header relocation to end of disk
  - Automatic filesystem expansion
- **Systemd Mount Unit**: /home mounted via systemd using PARTLABEL (device-independent)
- **Update Safety**: Update to inactive partition, switch on success

### Configuration Persistence

The system preserves critical configuration across updates:

**Preserved Settings** (stored in /home/.system-config/):
- SSH host keys (/etc/ssh/ssh_host_*)
- Hostname (/etc/hostname)
- Machine ID (/etc/machine-id)
- WPA Supplicant configuration (/etc/wpa_supplicant/)
- ConnMan network settings (/var/lib/connman/)
- SWUpdate configuration (/etc/swupdate/)

**Lifecycle:**
- `persist-config.service`: Runs before shutdown/reboot to save configs
- `restore-config.service`: Runs at boot to restore saved configs

**User Data** (in /home/thebrutzler/):
- User files and directories persist automatically

## Common Tasks

### Build brutzelboy
```bash
bitbake brutzelboy
```

### Build Update Packages
```bash
# Rootfs-only update (recommended for most updates)
bitbake brutzelboy-swupdate

# Full update with bootloader (when bootloader needs updating)
bitbake brutzelboy-swupdate-full
```
The .swu files will be in `tmp/deploy/images/thebrutzler_v2/`

**Bootloader Version Tracking:**
- Current version stored in `/etc/bootloader-version`
- Synced to U-Boot environment variable `bootloader_version`
- Full updates only write bootloader if newer version detected

### Clean Build
```bash
bitbake -c cleanall <recipe-name>
```

### Build SDK
```bash
bitbake <image-name> -c populate_sdk
```

### List Available Recipes
```bash
bitbake-layers show-recipes
```

### Show Layer Configuration
```bash
bitbake-layers show-layers
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
# Rootfs only
swupdate -i brutzelboy-swupdate-thebrutzler_v2.swu

# Full update with bootloader
swupdate -i brutzelboy-swupdate-full-thebrutzler_v2.swu
```

**Bootloader Updates:**
- Hardware compatibility checked against `/etc/hwrevision` (version 2.0)
- Bootloader version checked before updating (only if newer)
- Version information stored in U-Boot environment
- Check current bootloader version: `fw_printenv bootloader_version`
- U-Boot environment configuration: `/etc/fw_env.config`

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

## Troubleshooting

### Build Failures
1. Check disk space: `df -h`
2. Verify all dependencies are installed
3. Clean the build: `bitbake -c cleanall <failing-recipe>`
4. Check build logs in `bitbake-builds/poky-whinlatter/build/tmp/work/`

### Environment Issues
```bash
# Re-source the environment
source init-build-env
```

### Layer Conflicts
```bash
# Verify layer compatibility
bitbake-layers show-layers
```

## Pre-commit Hooks

This project uses [pre-commit](https://pre-commit.com/) to maintain code quality and consistency. Pre-commit hooks automatically check your changes before committing.

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

---

**Maintainer**: Platinenmacher
**Version**: 0.2.0
**Last Updated**: December 2025
