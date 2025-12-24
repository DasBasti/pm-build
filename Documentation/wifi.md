# How to use wifi with Platinenmacher Linux

The distribution uses connman for network connection management.

## Enable wifi
```
connmanctl enable wifi
```

## Scan for wifi networks
```
connmanctl scan wifi
connmanctl services
```

## Connect to a new WiFi network
Connecting is handled by the connman interactive terminal
```
connmanctl
connmanctl> agent onagent on
# Enter passphrase
connmanctl> quit
```
