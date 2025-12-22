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
An image for the brutzelboy during development.

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
- **Image recipes**: Standard image definitions
- **Package groups**: Curated software collections

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

## Common Tasks

### Build brutzelboy
```bash
bitbake brutzelboy
```

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
