# System Updates with SWUpdate

Platinenmacher Linux uses SWUpdate for A/B (dual-rootfs) system updates, allowing safe updates with automatic rollback on failure.

## Web Interface

Access the SWUpdate web interface at:
```
http://<device-ip>:8080
```

Upload the `.swu` file through the web interface to perform the update.

## Command Line Updates

### Rootfs Update (Recommended)
For most updates that only change the root filesystem:
```bash
swupdate -i brutzelboy-swupdate-thebrutzler_v2.swu
```

### Full Update with Bootloader
When the bootloader needs updating:
```bash
swupdate -i brutzelboy-swupdate-full-thebrutzler_v2.swu
```

**Note:** Full updates check bootloader version and only update if newer.

## Checking Update Status

### Check current rootfs slot
```bash
fw_printenv boot_slot
```

### Check bootloader version
```bash
fw_printenv bootloader_version
```

### View hardware revision
```bash
cat /etc/hwrevision
```

## Configuration Persistence

The system automatically preserves critical configuration across updates:

**Preserved Settings:**
- SSH host keys (`/etc/ssh/ssh_host_*`)
- Hostname (`/etc/hostname`)
- Machine ID (`/etc/machine-id`)
- Network settings (`/var/lib/connman/`)
- WPA Supplicant configuration (`/etc/wpa_supplicant/`)
- SWUpdate configuration (`/etc/swupdate/`)

**User Data:**
- Everything in `/home/thebrutzler/` persists automatically

## How A/B Updates Work

1. The system has two root filesystem partitions (A and B)
2. Updates are written to the inactive partition
3. After successful update, the bootloader switches to the new partition
4. If the new system fails to boot, it automatically rolls back to the previous partition
5. Your data in `/home` is always safe and accessible

## Troubleshooting

### Check SWUpdate service status
```bash
systemctl status swupdate
```

### View SWUpdate logs
```bash
journalctl -u swupdate -f
```

### Manual partition check
```bash
lsblk
```
