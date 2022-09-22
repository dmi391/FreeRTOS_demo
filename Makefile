
include ./paths
#From file 'paths':
#TOOLS
#RISCV_LD_LIBRARY_PATH

XLEN ?= 32
CROSS   = $(TOOLS)riscv64-unknown-elf-

CC      = $(CROSS)gcc
CPP     = $(CROSS)cpp
OBJCOPY = $(CROSS)objcopy
ARCH    = $(CROSS)ar
OBJDUMP = $(CROSS)objdump
SIZE    = $(CROSS)size

DEBUG ?= 0
BASE_ADDRESS ?= 0x10000000

ifeq ($(XLEN), 64)
    MARCH = rv64g
    MABI = lp64
	STACK_SIZE = 600
else
    MARCH = rv32ima
    MABI = ilp32
	STACK_SIZE = 300
endif

BUILD_DIR       = build
RTOS_SOURCE_DIR = ./FreeRTOS/Source
DEMO_SOURCE_DIR = ./FreeRTOS/Demo/Common/Minimal
#RTOS_SOURCE_DIR = $(abspath ./FreeRTOS/Source)
#DEMO_SOURCE_DIR = $(abspath ./FreeRTOS/Demo/Common/Minimal)

CPPFLAGS = \
	-DportasmHANDLE_INTERRUPT=handle_trap \
	-I ./src \
	-I ./FreeRTOS/Demo/Common/include \
	-I $(RTOS_SOURCE_DIR)/include \
	-I $(RTOS_SOURCE_DIR)/portable/GCC/RISC-V \
	-I $(RTOS_SOURCE_DIR)/portable/GCC/RISC-V/chip_specific_extensions/RV32I_CLINT_no_extensions
CFLAGS  = -march=$(MARCH) -mcmodel=medany \
	-Wall \
	-fmessage-length=0 \
	-ffunction-sections \
	-fdata-sections \
	-fno-builtin-printf
ASFLAGS = -march=$(MARCH) -mcmodel=medany
LDFLAGS = -nostartfiles \
	-Xlinker --gc-sections \
	-Xlinker --defsym=__stack_size=$(STACK_SIZE) \
	-Wl,-Map,$@.map


ifeq ($(DEBUG), 1)
    CFLAGS += -Og -ggdb3
else
    CFLAGS += -Os
endif

SRCS = ./src/main.c ./src/main_blinky.c ./src/riscv-virt.c ./src/htif.c \
	$(DEMO_SOURCE_DIR)/EventGroupsDemo.c \
	$(DEMO_SOURCE_DIR)/TaskNotify.c \
	$(DEMO_SOURCE_DIR)/TimerDemo.c \
	$(DEMO_SOURCE_DIR)/blocktim.c \
	$(DEMO_SOURCE_DIR)/dynamic.c \
	$(DEMO_SOURCE_DIR)/recmutex.c \
	$(RTOS_SOURCE_DIR)/event_groups.c \
	$(RTOS_SOURCE_DIR)/list.c \
	$(RTOS_SOURCE_DIR)/queue.c \
	$(RTOS_SOURCE_DIR)/stream_buffer.c \
	$(RTOS_SOURCE_DIR)/tasks.c \
	$(RTOS_SOURCE_DIR)/timers.c \
	$(RTOS_SOURCE_DIR)/portable/MemMang/heap_4.c \
	$(RTOS_SOURCE_DIR)/portable/GCC/RISC-V/port.c

ASMS = ./src/start.S \
	$(RTOS_SOURCE_DIR)/portable/GCC/RISC-V/portASM.S

OBJS = $(SRCS:%.c=$(BUILD_DIR)/%$(XLEN).o) $(ASMS:%.S=$(BUILD_DIR)/%$(XLEN).o)
DEPS = $(SRCS:%.c=$(BUILD_DIR)/%$(XLEN).d) $(ASMS:%.S=$(BUILD_DIR)/%$(XLEN).d)

.PHONY: all
all: $(BUILD_DIR)/RTOSDemo$(XLEN).elf

$(BUILD_DIR)/RTOSDemo$(XLEN).elf: $(OBJS) $(BUILD_DIR)/fake_rom$(BASE_ADDRESS).lds Makefile
	$(CC) $(LDFLAGS) $(OBJS) -T$(BUILD_DIR)/fake_rom$(BASE_ADDRESS).lds -o $@
	@echo ""
	@echo "Post-build:"
	$(OBJDUMP) -S $@ > $@.txt
	$(OBJCOPY) -O verilog $@ $@.hex
	@echo ""
	@$(SIZE) --format=berkeley $@
	@echo ""
	@echo "Done"

$(BUILD_DIR)/%$(XLEN).o: %.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/%$(XLEN).o: %.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(ASFLAGS) -MMD -MP -c $< -o $@

# Run lds through the C preprocessor, to replace BASE_ADDRESS with the actual
# value. It might be simpler to use sed instead.
$(BUILD_DIR)/%$(BASE_ADDRESS).lds: ./src/fake_rom.lds Makefile
	$(CPP) $(CPPFLAGS) -DBASE_ADDRESS=$(BASE_ADDRESS) $< | grep -v '^#' > $@


.PHONY: clean
clean:
	@echo "Clean..."
	@rm -rf $(BUILD_DIR)/*

-include $(DEPS)
