# Benchmarking Tools

Platinenmacher Linux includes a comprehensive set of benchmarking tools for testing system performance.

## CPU Benchmarks

### Dhrystone
Integer performance benchmark:
```bash
dhrystone
```

### CPUburn
Stress test for ARM CPUs:
```bash
# Run for a specific duration (be careful - generates heat!)
cpuburn-a53  # For ARM Cortex-A53 cores
```

### Sysbench CPU Test
```bash
# CPU benchmark with 4 threads
sysbench cpu --threads=4 run

# CPU benchmark with prime numbers
sysbench cpu --cpu-max-prime=20000 run
```

### Stress-ng
Comprehensive stress testing:
```bash
# CPU stress test for 60 seconds
stress-ng --cpu 4 --timeout 60s --metrics-brief

# Matrix operations stress test
stress-ng --matrix 4 --timeout 30s
```

## Memory Benchmarks

### Sysbench Memory Test
```bash
# Memory read/write benchmark
sysbench memory run

# Sequential memory access
sysbench memory --memory-oper=read --memory-access-mode=seq run
```

### LMbench
Memory latency and bandwidth:
```bash
# Memory bandwidth
bw_mem 10M rd
bw_mem 10M wr

# Memory latency
lat_mem_rd 100M 128
```

## Storage Benchmarks

### Bonnie++
File system performance:
```bash
# Run with default settings
bonnie++

# Specify test size (in MB)
bonnie++ -s 2048

# Test on specific directory
bonnie++ -d /home/thebrutzler/
```

### FIO (Flexible I/O Tester)
Advanced I/O testing:
```bash
# Random read test
fio --name=randread --ioengine=libaio --iodepth=16 --rw=randread --bs=4k --size=1G --numjobs=1 --runtime=60 --time_based

# Sequential write test
fio --name=seqwrite --ioengine=libaio --iodepth=1 --rw=write --bs=1M --size=1G --numjobs=1

# Quick mixed workload test
fio --name=mixed --ioengine=libaio --iodepth=4 --rw=randrw --rwmixread=70 --bs=4k --size=512M --runtime=30
```

### IOzone
File system analysis:
```bash
# Automatic mode
iozone -a

# Specific test
iozone -r 4k -s 100M
```

### hdparm
Disk performance:
```bash
# Read speed test
sudo hdparm -t /dev/mmcblk0

# Cached read speed
sudo hdparm -T /dev/mmcblk0
```

## Network Benchmarks

### iperf3
Network throughput testing:
```bash
# Server mode
iperf3 -s

# Client mode (test to server at 192.168.1.100)
iperf3 -c 192.168.1.100

# UDP test with 100Mbps bandwidth
iperf3 -c 192.168.1.100 -u -b 100M

# Bidirectional test
iperf3 -c 192.168.1.100 --bidir
```

## GPU Benchmarks

### glmark2
OpenGL ES performance:
```bash
# Run default benchmark suite
glmark2-es2

# Fullscreen mode
glmark2-es2 --fullscreen

# Offscreen rendering (no display)
glmark2-es2 --off-screen
```

## Real-Time Performance

### rt-tests
Real-time latency testing:
```bash
# Cyclictest - real-time latency test
sudo cyclictest --mlockall --smp --priority=80 --interval=200 --distance=0 --duration=1m

# Pi stress - stress test for real-time systems
sudo pi_stress
```

## Input Device Testing

### evtest
Event device testing:
```bash
# List all input devices
evtest

# Test specific device
sudo evtest /dev/input/event0
```

## System Performance Analysis

### perf
Linux performance analysis:
```bash
# Record system-wide performance
sudo perf record -a sleep 10

# View the report
sudo perf report

# Live system monitoring
sudo perf top

# CPU statistics
sudo perf stat <command>
```

### systemd-analyze
Boot and service performance:
```bash
# Total boot time
systemd-analyze

# Per-service boot time
systemd-analyze blame

# Critical chain analysis
systemd-analyze critical-chain
```

## Custom Memory Bandwidth Benchmark

### pmbw
Parallel Memory Bandwidth Benchmark:
```bash
# Run standard benchmark
pmbw

# Run with specific options
pmbw -s <size>
```

## Tips for Benchmarking

1. **Consistent Environment**: Close unnecessary applications before running benchmarks
2. **Multiple Runs**: Run benchmarks multiple times and average the results
3. **Temperature**: Monitor temperature during CPU/GPU stress tests (check `/sys/class/thermal/thermal_zone*/temp`)
4. **Storage**: For storage benchmarks, ensure sufficient free space
5. **Network**: For network benchmarks, use wired connection when possible for consistent results

## Monitoring During Tests

### CPU Temperature
```bash
cat /sys/class/thermal/thermal_zone0/temp
```

### CPU Frequency
```bash
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq
```

### Memory Info
```bash
free -h
cat /proc/meminfo
```
