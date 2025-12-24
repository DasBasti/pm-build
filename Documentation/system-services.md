# System Services and Management

Platinenmacher Linux uses systemd for system and service management.

## Viewing System Services

### List all services
```bash
systemctl list-units --type=service
```

### Check specific service status
```bash
systemctl status <service-name>
```

Example:
```bash
systemctl status connman
systemctl status swupdate
systemctl status sshd
```

## Managing Services

### Start a service
```bash
sudo systemctl start <service-name>
```

### Stop a service
```bash
sudo systemctl stop <service-name>
```

### Restart a service
```bash
sudo systemctl restart <service-name>
```

### Enable service at boot
```bash
sudo systemctl enable <service-name>
```

### Disable service at boot
```bash
sudo systemctl disable <service-name>
```

## System Logs

### View all system logs
```bash
journalctl
```

### View logs for a specific service
```bash
journalctl -u <service-name>
```

### Follow logs in real-time
```bash
journalctl -f
```

### View logs since last boot
```bash
journalctl -b
```

### View logs from previous boot
```bash
journalctl -b -1
```

### Filter by time
```bash
journalctl --since "1 hour ago"
journalctl --since "2024-12-24 10:00:00"
```

## Power Management

### Reboot the system
```bash
sudo reboot
```

### Power off the system
```bash
sudo poweroff
```

### Suspend the system
```bash
sudo systemctl suspend
```

## System Information

### View system status
```bash
systemctl status
```

### Analyze boot time
```bash
systemd-analyze
```

### Show boot time per service
```bash
systemd-analyze blame
```

### Check system hostname
```bash
hostnamectl
```

### Change hostname
```bash
sudo hostnamectl set-hostname <new-hostname>
```

## Key Platinenmacher Services

### persist-config.service
Saves system configuration before shutdown/reboot
```bash
systemctl status persist-config
```

### restore-config.service
Restores saved configuration at boot
```bash
systemctl status restore-config
```

### resize-userdata.service
Expands /home partition on first boot
```bash
systemctl status resize-userdata
```

### swupdate-bootenv.service
Syncs bootloader version to U-Boot environment
```bash
systemctl status swupdate-bootenv
```

## Monitoring Resources

### View system resource usage
```bash
systemctl status
```

### View detailed resource usage
```bash
systemd-cgtop
```

### Check disk usage
```bash
df -h
```

### Check memory usage
```bash
free -h
```
