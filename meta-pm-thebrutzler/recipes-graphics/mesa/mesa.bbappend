# Fix for mesa 25.x: kmsro PACKAGECONFIG was removed upstream
# The individual GPU drivers (panfrost, lima) are sufficient

# Override the meta-rockchip append to remove the invalid 'kmsro' option
# For rk3566 (our target), we only need panfrost driver
PACKAGECONFIG:remove:rk3566 = "kmsro"
python () {
    pkgconfig = d.getVar('PACKAGECONFIG') or ''
    # Remove 'kmsro' if it exists
    pkgconfig = ' '.join([item for item in pkgconfig.split() if item != 'kmsro'])
    d.setVar('PACKAGECONFIG', pkgconfig)
}
