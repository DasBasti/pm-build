#!/bin/bash

source ./init-build-env

# nice -n 10: Lower CPU priority (0=normal, 19=lowest)
# ionice -c 2 -n 7: Best-effort I/O class, priority 7 (0=highest, 7=lowest)
nice -n 10 ionice -c 2 -n 7 bitbake brutzelboy brutzelboy-swupdate brutzelboy-swupdate-full
