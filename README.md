# FreeRTOS_demo

This project demonstrates using FreeRTOS on RISC-V embedded system.  
There are two tasks (threads) - send and receive. Send task sends integers to receive task through a queue. Both tasks output their sending/receiving to memory log and Spike terminal (using `htif`). Tasks outputting is protected with mutex.

## Quick start

Set actual paths in file `paths`.

Build project:

    $ make XLEN=64 DEBUG=1

Launch with hardware:

    $ ./launch-sh/openocd_gdb_launch.sh ./build/RTOSDemo64.elf
        <stopped at main_blinky()>
    (gdb) continue
    (gdb) Ctrl+C
    (gdb) dump memory /tmp/log (&_LOG_START_ADDRESS) (&_LOG_START_ADDRESS + 1000)

Launch with Spike:

    $ ./launch-sh/spike_openocd_gdb_launch.sh ./build/RTOSDemo64.elf
        <stopped at main_blinky()>
    (gdb) continue
    (gdb) Ctrl+C
    (gdb) dump memory /tmp/log (&_LOG_START_ADDRESS) (&_LOG_START_ADDRESS + 1000)

## Results

At hardware launch and Spike launch results are output to memory log.  
And at Spike launch results are also output to Spike terminal.

Output format:

    <mcycle_value>: Tx: send <counter>
    <mcycle_value>: Rx: received <counter>

See memory log:

    $ cat /tmp/log

        Hello, FreeRTOS!

        575040508: Tx: send 1
        575048515: Rx: received 1
        577540048: Tx: send 2
        577544282: Rx: received 2
        580040028: Tx: send 3
        580043779: Rx: received 3
        582540028: Tx: send 4
        582543373: Rx: received 4
        ...

Send period is 0.1 second (frequency is 25 MHz).

## In Visual Studio Code

Set actual paths in files `paths`, `c_cpp_properties.json`, `launch.json`, `tasks.json`.

Build project: `Ctrl+Shift+B`.

Launch: `F5`.

----
