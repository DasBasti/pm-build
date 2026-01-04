# Fix for mesa 25.x: kmsro PACKAGECONFIG was removed upstream
# The individual GPU drivers (panfrost, lima) are sufficient

# Override the meta-rockchip append to remove the invalid 'kmsro' option
# For rk3566 (our target), we need panfrost + libclc for the Gallium driver
PACKAGECONFIG:remove:rk3566 = "kmsro"

# Mesa 25.x requires libclc for panfrost Gallium driver support
# See: GALLIUMDRIVERS .= "${@bb.utils.contains('PACKAGECONFIG', 'panfrost libclc', ',panfrost', '', d)}"
PACKAGECONFIG:append:rk3566 = " libclc gallium"
PACKAGECONFIG:append:rk3568 = " libclc gallium"

python () {
    pkgconfig = d.getVar('PACKAGECONFIG') or ''
    # Remove 'kmsro' if it exists (removed in mesa 25.x)
    pkgconfig = ' '.join([item for item in pkgconfig.split() if item != 'kmsro'])
    d.setVar('PACKAGECONFIG', pkgconfig)
}
