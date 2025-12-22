# Copilot Coding Agent Instructions

This document provides essential information for efficient development in this repository.

## Repository Overview

**Platinenmacher Linux Build System** - A Yocto/BitBake build system for embedded Linux on the TheBrutzler v2 board (Rockchip RK3566 SoC).

- **Project Type**: Yocto Project build system
- **Distribution**: Platinenmacher Linux (based on poky)
- **Yocto Release**: Whinlatter
- **Target Machine**: thebrutzler_v2 (ARM64/aarch64)
- **Size**: Medium (~15 custom recipes, relies heavily on git submodules)

## Repository Structure

```
pm-build/
├── .github/
│   ├── workflows/build.yml     # CI: pre-commit checks on push/PR to main
│   └── scripts/                # CI helper scripts (oelint-check.sh)
├── .pre-commit-config.yaml     # Pre-commit hook configuration
├── .oelint-adv/soc-families.json  # OE linter custom SOC families
├── init-build-env              # Main environment setup script (source this!)
├── build.sh                    # Simple build wrapper script
├── meta-platinenmacher/        # Common distro layer (PRIORITY: 99)
│   ├── conf/distro/platinenmacher-linux.conf  # Distro configuration
│   ├── conf/layer.conf         # Layer metadata
│   ├── recipes-images/         # Image recipes (brutzelboy, swupdate)
│   ├── recipes-core/           # System services (persist-config, resize-userdata)
│   ├── recipes-support/        # Support packages (swupdate components)
│   ├── recipes-benchmark/      # Benchmark tools
│   └── wic/platinenmacher-ab.wks  # A/B partition layout
├── meta-pm-thebrutzler/        # Hardware-specific BSP layer (PRIORITY: 99)
│   ├── conf/machine/thebrutzler_v2.conf  # Machine definition
│   ├── recipes-bsp/rkbin/      # Rockchip binary packages
│   ├── recipes-kenel/linux/    # Kernel customizations (NOTE: typo in folder name)
│   └── bin/flash-bmap          # Flashing utility
├── bitbake/                    # BitBake submodule
└── bitbake-builds/
    └── poky-whinlatter/
        ├── build/conf/         # Build configuration (local.conf, bblayers.conf)
        ├── buildtools/         # SDK tools
        └── layers/             # Upstream Yocto layers (submodules)
```

## Code Quality & CI

### Pre-commit Hooks (Required)

Always run before committing:

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

**Configured hooks:**
1. `trailing-whitespace` - Removes trailing whitespace
2. `end-of-file-fixer` - Ensures files end with newline
3. `check-yaml` - Validates YAML files
4. `check-added-large-files` - Prevents large file commits
5. `oelint-adv` - OE recipe linter for `.bb`, `.bbappend`, `.bbclass`, `.inc`, `.conf` files

### GitHub Actions CI

The `build.yml` workflow runs on push/PR to `main`:
- Checks out with `submodules: recursive`
- Runs `pre-commit run --all-files`

**Validation before PR:**
```bash
pre-commit run --all-files
```

## Working with Yocto Recipes

### Recipe File Conventions

- Recipes: `<name>_<version>.bb` (e.g., `pmbw_git.bb`)
- Appends: `<name>_%.bbappend` or `<name>_<version>.bbappend`
- Classes: `*.bbclass`
- Include files: `*.inc`
- Config files: `*.conf`

### Creating/Editing Recipes

Location by type:
- **Images**: `meta-platinenmacher/recipes-images/images/`
- **Core services**: `meta-platinenmacher/recipes-core/`
- **BSP/kernel**: `meta-pm-thebrutzler/recipes-kenel/linux/` (note typo: "kenel")
- **Benchmark**: `meta-platinenmacher/recipes-benchmark/`

### OE Linter Configuration

Custom SOC families are defined in `.oelint-adv/soc-families.json`:
- Includes: arm, rk3308, rk3326, rk3328, rk3399, rk3566, rk3568, rk3588, rk3588s

The linter script (`.github/scripts/oelint-check.sh`) uses `--fix` and `--exit-zero`.

## Key Configuration Files

| File | Purpose |
|------|---------|
| `bitbake-builds/poky-whinlatter/build/conf/local.conf` | Machine/distro selection |
| `bitbake-builds/poky-whinlatter/build/conf/bblayers.conf` | Layer paths |
| `meta-platinenmacher/conf/distro/platinenmacher-linux.conf` | Distro features |
| `meta-pm-thebrutzler/conf/machine/thebrutzler_v2.conf` | Hardware definition |

## Build Commands (Reference Only)

> **Note**: Full Yocto builds require ~50GB disk, 8GB+ RAM, and Ubuntu 22.04. Build commands are documented here for reference but cannot run in most CI environments.

```bash
# Initialize environment (always required first)
source init-build-env

# Build main image
bitbake brutzelboy

# Build SWUpdate packages
bitbake brutzelboy-swupdate
bitbake brutzelboy-swupdate-full

# Clean a recipe
bitbake -c cleanall <recipe-name>

# Show layers
bitbake-layers show-layers

# List recipes
bitbake-layers show-recipes
```

## Important Notes for Code Changes

1. **Submodules Required**: This repo uses git submodules. Clone with `--recursive`:
   ```bash
   git clone --recursive <repo-url>
   ```

2. **Recipe typo**: The kernel recipes are in `recipes-kenel/` (not `recipes-kernel/`). Do NOT rename this folder as it would break existing configurations.

3. **Layer priority**: Both custom layers have priority 99 (highest wins for same recipe).

4. **Kernel class**: Uses `kernel-fit-extra-artifacts` (not the older `kernel-fitimage`).

5. **systemd**: The distro uses systemd as init manager (`POKY_INIT_MANAGER`).

6. **A/B Updates**: Images support SWUpdate with A/B partition scheme.

## File Types That Require Linting

When modifying these file types, run pre-commit:
- `*.bb` - BitBake recipes
- `*.bbappend` - Recipe appends
- `*.bbclass` - BitBake classes
- `*.inc` - Include files
- `*.conf` - Configuration files

## Quick Reference Commands

```bash
# Validate all files before commit
pre-commit run --all-files

# Check git status
git status

# Check submodule status
git submodule status
```

## Trust These Instructions

The information in this file has been validated. Only search the codebase if:
- Information appears incomplete
- An error suggests the documentation is outdated
- You need details about a specific recipe not covered here
