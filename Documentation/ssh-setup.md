# SSH Access Setup

Platinenmacher Linux includes OpenSSH server for remote access. The default user `thebrutzler` is pre-configured with passwordless sudo access.

## Default Configuration

- **User**: thebrutzler (UID 1000)
- **Authentication**: SSH key-based (no password login)
- **Sudo**: Passwordless sudo access enabled
- **Home Directory**: /home/thebrutzler (persists across updates)

## Setting Up SSH Keys

### From Your Local Machine

1. Generate an SSH key pair (if you don't have one):
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

2. Copy your public key to the device:

**Option A - Using serial console:**
```bash
# On the device (via serial console), create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Copy your public key content and paste it
cat >> ~/.ssh/authorized_keys
# Paste your public key, then press Ctrl+D

# Set correct permissions
chmod 600 ~/.ssh/authorized_keys
```

**Option B - Using USB drive or SD card:**
```bash
# Mount USB drive on device
sudo mount /dev/sda1 /mnt
cp /mnt/id_ed25519.pub ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sudo umount /mnt
```

**Option C - Using ssh-copy-id (if password auth is temporarily enabled):**
```bash
ssh-copy-id thebrutzler@<device-ip>
```

3. Connect via SSH:
```bash
ssh thebrutzler@<device-ip>
```

## Finding Device IP Address

### On the device (via serial console)
```bash
# Show all network interfaces
ip addr show

# Show only the IP address
hostname -I
```

### On your local network
```bash
# Scan for devices (requires nmap)
nmap -sn 192.168.1.0/24

# Check DHCP leases on your router
# (method varies by router)
```

## SSH Configuration

### Server Configuration
The SSH server configuration is at `/etc/ssh/sshd_config`:
```bash
sudo vi /etc/ssh/sshd_config
```

### Restart SSH Service
After making changes:
```bash
sudo systemctl restart sshd
```

### Check SSH Service Status
```bash
systemctl status sshd
```

## SSH Host Keys

SSH host keys are automatically preserved across system updates:
- Keys stored in: `/etc/ssh/ssh_host_*`
- Backed up by: `persist-config.service`
- Restored by: `restore-config.service`

This means you won't get "host key changed" warnings after system updates.

## Advanced SSH Usage

### SSH with Custom Port
If you change the SSH port:
```bash
ssh -p <port> thebrutzler@<device-ip>
```

### SSH Config File
Add device to `~/.ssh/config` on your local machine:
```
Host brutzelboy
    HostName <device-ip>
    User thebrutzler
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

Then connect with:
```bash
ssh brutzelboy
```

### Copy Files with SCP
```bash
# Copy to device
scp file.txt thebrutzler@<device-ip>:/home/thebrutzler/

# Copy from device
scp thebrutzler@<device-ip>:/home/thebrutzler/file.txt .

# Copy directory recursively
scp -r folder/ thebrutzler@<device-ip>:/home/thebrutzler/
```

### Copy Files with RSYNC
```bash
# Sync local directory to device
rsync -avz /local/path/ thebrutzler@<device-ip>:/home/thebrutzler/path/

# Sync from device
rsync -avz thebrutzler@<device-ip>:/home/thebrutzler/path/ /local/path/
```

## Multiple SSH Keys

### Add Multiple Authorized Keys
Edit `~/.ssh/authorized_keys`:
```bash
vi ~/.ssh/authorized_keys
```

Add one public key per line. Each key allows a different user/computer to connect.

### Use Different Keys for Different Devices
On your local machine's `~/.ssh/config`:
```
Host brutzelboy1
    HostName 192.168.1.100
    User thebrutzler
    IdentityFile ~/.ssh/brutzelboy1_key

Host brutzelboy2
    HostName 192.168.1.101
    User thebrutzler
    IdentityFile ~/.ssh/brutzelboy2_key
```

## Security Best Practices

### Disable Password Authentication (Recommended)
Edit `/etc/ssh/sshd_config`:
```
PasswordAuthentication no
```

### Change Default SSH Port
Edit `/etc/ssh/sshd_config`:
```
Port 2222
```

### Limit SSH Access by IP
Edit `/etc/ssh/sshd_config`:
```
AllowUsers thebrutzler@192.168.1.*
```

### Use SSH Key Passphrase
When generating keys, always use a strong passphrase:
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# Enter a strong passphrase when prompted
```

## Troubleshooting

### Cannot Connect
1. Check if SSH service is running:
```bash
systemctl status sshd
```

2. Check if port 22 is listening:
```bash
sudo netstat -tlnp | grep :22
```

3. Verify network connectivity:
```bash
ping <device-ip>
```

### Permission Denied
1. Verify authorized_keys permissions:
```bash
ls -la ~/.ssh/
# authorized_keys should be 600
# .ssh directory should be 700
```

2. Check SSH key is loaded:
```bash
ssh-add -l
```

3. Try with verbose output:
```bash
ssh -v thebrutzler@<device-ip>
```

### Host Key Verification Failed
If you see "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED":
```bash
# Remove old host key (on your local machine)
ssh-keygen -R <device-ip>
```

Note: This shouldn't happen with Platinenmacher Linux due to host key persistence.

## Serial Console Alternative

If SSH is not working, you can always access the system via serial console:
- **Baud rate**: 1500000
- **User**: thebrutzler (or root)
- **Password**: Just press Enter (no password required on serial console)

Serial console access allows you to fix SSH configuration issues.
