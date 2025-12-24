# U-Boot Environment Management

Platinenmacher Linux uses U-Boot as the bootloader, which stores configuration in environment variables. These can be accessed and modified from Linux using the `fw_printenv` and `fw_setenv` utilities.

## Viewing Environment Variables

### List all U-Boot environment variables
```bash
fw_printenv
```

### View a specific variable
```bash
fw_printenv <variable-name>
```

Examples:
```bash
fw_printenv boot_slot
fw_printenv bootloader_version
fw_printenv bootcount
fw_printenv bootlimit
```

## Modifying Environment Variables

**Warning:** Modifying U-Boot environment variables can prevent your system from booting. Only change variables if you understand their purpose.

### Set a variable
```bash
sudo fw_setenv <variable-name> <value>
```

Example:
```bash
sudo fw_setenv custom_var "my_value"
```

### Delete a variable
```bash
sudo fw_setenv <variable-name>
```

## Key Environment Variables

### boot_slot
Current active root filesystem partition (A or B):
```bash
fw_printenv boot_slot
```
- `A`: System is booting from partition A
- `B`: System is booting from partition B

### bootloader_version
Version of the installed bootloader:
```bash
fw_printenv bootloader_version
```

### bootcount
Number of boot attempts for current slot:
```bash
fw_printenv bootcount
```
Automatically resets to 0 on successful boot.

### bootlimit
Maximum boot attempts before rollback:
```bash
fw_printenv bootlimit
```
Default is typically 3 attempts.

### upgrade_available
Flag indicating pending update:
```bash
fw_printenv upgrade_available
```
- `1`: Update is installed, waiting for validation
- `0` or unset: Normal operation

## A/B Update Status

### Check current boot configuration
```bash
fw_printenv boot_slot
fw_printenv upgrade_available
fw_printenv bootcount
```

### After successful update
Once the system boots successfully after an update, the bootcount is automatically reset and the upgrade is confirmed.

## Configuration File

The U-Boot environment configuration is stored in:
```
/etc/fw_env.config
```

This file specifies where the U-Boot environment is stored on the device.

### View configuration
```bash
cat /etc/fw_env.config
```

## Troubleshooting

### Cannot read environment
If you get permission errors:
```bash
sudo fw_printenv
```

### Environment corrupted
If the environment is corrupted, U-Boot will use default values. The system will still boot, but custom settings may be lost.

### Check environment from U-Boot console
If Linux won't boot, you can access U-Boot environment from the serial console:
```
# At U-Boot prompt
printenv
setenv <variable> <value>
saveenv
```

## Safety Notes

1. **Never modify boot_slot manually** - This is managed by SWUpdate and U-Boot
2. **bootcount is automatic** - Let the system manage boot counting
3. **Take note before changes** - Always record current values before modifying
4. **Test after changes** - Verify system boots correctly after environment changes
5. **Keep serial console access** - Useful for recovery if boot fails

## Common Tasks

### Verify bootloader version
```bash
fw_printenv bootloader_version
cat /etc/bootloader-version
```
These should match after a successful full update.

### Check for pending update
```bash
fw_printenv upgrade_available
```

### Monitor boot reliability
```bash
fw_printenv bootcount
fw_printenv bootlimit
```
If bootcount approaches bootlimit, investigate boot issues.

### Add custom boot parameter
```bash
sudo fw_setenv custom_bootargs "console=ttyS2,1500000"
```

## Integration with SWUpdate

SWUpdate automatically manages these variables during system updates:
- Sets `boot_slot` to the new partition after update
- Sets `upgrade_available=1` before first boot of new system
- Monitors `bootcount` for automatic rollback
- Updates `bootloader_version` after bootloader updates

The system handles all of this automatically - manual intervention is rarely needed.
