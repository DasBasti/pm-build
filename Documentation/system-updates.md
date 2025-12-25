# System Updates with SWUpdate

Platinenmacher Linux uses SWUpdate for A/B (dual-rootfs) system updates, allowing safe updates with automatic rollback on failure.

## Security: Signed Updates

**All SWUpdate packages are cryptographically signed** using RSA-4096 to ensure update integrity and authenticity.

### Development Key (Current)

For development and testing, a development key is included in the repository:

**Location:**
- Private key: `meta-platinenmacher/recipes-support/swupdate-key/files/swupdate-development-key.pem`
- Public key: `meta-platinenmacher/recipes-support/swupdate-key/files/swupdate-development-key.pub`

**On Device:**
- Public key installed at: `/etc/swupdate/certs/swupdate.pem`
- SWUpdate verifies all updates against this certificate
- Unsigned or incorrectly signed updates are **rejected**

### ⚠️ Production Deployment Warning

**DO NOT USE THE DEVELOPMENT KEY IN PRODUCTION!**

For production systems, you **must**:

1. **Generate a new RSA key pair** on a secure system:
   ```bash
   openssl genrsa -out swupdate-production-key.pem 4096
   openssl rsa -in swupdate-production-key.pem -outform PEM -pubout \
       -out swupdate-production-key.pub
   ```

2. **Secure the private key**:
   - Store in a Hardware Security Module (HSM), secrets manager, or secure vault
   - **NEVER** commit the production private key to version control
   - Restrict access to authorized build systems only

3. **Update the recipe**:
   - Replace `swupdate-development-key.pub` in `meta-platinenmacher/recipes-support/swupdate-key/files/`
   - Update `SWUPDATE_PRIVATE_KEY` path in `brutzelboy-swupdate.inc` to point to secure location

4. **Rebuild all images and SWUpdate packages**

### How Signing Works

1. **Build time**: The `.swu` package is signed with the private key
2. **Runtime**: SWUpdate verifies the signature using the public key on the device
3. **Deployment**: Only properly signed updates can be installed
4. **Protection**: Prevents installation of unauthorized or tampered updates

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
# use copyA when booted from Image A, useb copyB when bootet from Image B
swupdate -i brutzelboy-swupdate-thebrutzler_v2.swu -e stable,copy(A/B)
```

## Checking Update Status

### Check current rootfs slot
```bash
fw_printenv roo
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

## Update Package Structure

Each `.swu` file contains:
- `sw-description`: Libconfig format file describing the update
- Root filesystem image (`brutzelboy-thebrutzler_v2.rootfs.ext4`)
- Bootloader binaries (full updates only: `idbloader.img`, `u-boot.itb`)
- **RSA signature** for verification

The signature is automatically checked before installation.

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

### Verify signature verification is enabled
```bash
# Check if public key exists
ls -l /etc/swupdate/certs/swupdate.pem

# Test with unsigned update (should fail)
# Expected error: "Signature verification failed"
```

### Common signature errors
- `ERROR: Signature verification failed` - Update not signed or wrong key
- `ERROR: no public key available` - Missing `/etc/swupdate/certs/swupdate.pem`
