# Fix for mesa 25.x: kmsro PACKAGECONFIG was removed upstream
# The individual GPU drivers (panfrost, lima) are sufficient
# PACKAGECONFIG:remove:rk3566 = "kmsro"
