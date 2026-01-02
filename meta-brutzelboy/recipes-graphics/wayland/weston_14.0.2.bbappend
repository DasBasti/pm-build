# Explicit versioned bbappend to force enabling RDP backend
PACKAGECONFIG:${PN}:append = " rdp"
DEPENDS:append = " freerdp"
RDEPENDS:${PN}:append = " freerdp"
