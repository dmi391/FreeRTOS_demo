#!/bin/bash

source ./paths

ELF="$1"


SPIKE_LAUNCH="$SPIKE --rbb-port=9824 -m0x10000000:0x10000000 -H $ELF"
OPENOCD_LAUNCH="$OPENOCD -f $OPENOCD_CFG_SPIKE"
GDB_LAUNCH="$GDB -x $GDB_SCRIPT_SPIKE --silent $ELF"


# For Spike launch
export LD_LIBRARY_PATH="$LD_LIB_PATH"


#Launch: Spike + OpenOCD + GDB
xfce4-terminal \
--tab --title=Spike -e "$SPIKE_LAUNCH" \
--tab --title=OpenOCD -e "$OPENOCD_LAUNCH" \
--tab --title=GDB --hold -e "$GDB_LAUNCH"

exit 0
