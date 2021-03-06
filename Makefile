ifeq (1,$(VERBOSE))
quiet =
else
quiet = quiet_
endif

-include local.mk

TARGET ?= f4disco

TCHAIN_PREFIX = arm-none-eabi-
REMOVE_CMD = rm

USE_THUMB_MODE = YES

CDEFS    += -DDEBUG
CDEFS    += -DDEBUG_BAUDRATE=1000000

# MCU name, submodel and board
# - MCU used for compiler-option (-mcpu)
# - BOARD just passed as define (don't used '-' characters)
ifeq ($(TARGET),wifi)
MCU       = cortex-m4
CHIP      = STM32F411xE
BOARD     = F4_WIFI
SERIES    = STM32F4

CDEFS    += -mfpu=fpv4-sp-d16 -mfloat-abi=softfp
CDEFS    += -DUSE_HAL_DRIVER
CDEFS    += -DSTM32F411xE -DARM_MATH_CM4 -D__FPU_PRESENT=1
CDEFS    += -DHSE_VALUE=8000000UL

HAL_DRV  = STM32F4xx
HAL_DRV2 = stm32f4xx

TGT_SRC  = src/system_stm32f4xx.c 
TGT_SRC += src/stm32f4xx_it.c
TGT_ASRC = gcc/startup_stm32f411xe.s
TGT_LD   = -T./gcc/STM32F411RE_FLASH.ld
OOCD_TGT = stm32f4.cfg
endif

ifeq ($(TARGET),f4disco)
MCU       = cortex-m4
CHIP      = STM32F40x_1024k
BOARD     = F4_DISCO
SERIES    = STM32F4

CDEFS    += -mfpu=fpv4-sp-d16 -mfloat-abi=softfp
CDEFS    += -DUSE_HAL_DRIVER
CDEFS    += -DSTM32F407xx -DARM_MATH_CM4 -D__FPU_PRESENT=1
CDEFS    += -DHSE_VALUE=8000000UL

HAL_DRV  = STM32F4xx
HAL_DRV2 = stm32f4xx

TGT_SRC  = src/system_stm32f4xx.c 
TGT_SRC += src/stm32f4xx_it.c
TGT_ASRC = gcc/startup_stm32f407xx.s
TGT_LD   = -T./gcc/STM32F407VG_FLASH.ld
OOCD_TGT = stm32f4.cfg
endif

ifeq ($(TARGET),f3disco)
MCU       = cortex-m4
CHIP      = STM32F303xC
BOARD     = F3_DISCO
SERIES    = STM32F3

CDEFS    += -mfpu=fpv4-sp-d16 -mfloat-abi=softfp
CDEFS    += -DUSE_HAL_DRIVER
CDEFS    += -DSTM32F303xC -DARM_MATH_CM4 -D__FPU_PRESENT=1
CDEFS    += -DHSE_VALUE=8000000UL

HAL_DRV  = STM32F3xx
HAL_DRV2 = stm32f3xx

TGT_SRC  = src/system_stm32f3xx.c 
TGT_SRC += src/stm32f3xx_it.c
#TGT_SRC  += src/stm32f4_discovery.c 
TGT_ASRC = gcc/startup_stm32f303xc.s
TGT_LD   = -T./gcc/STM32F303VC_FLASH.ld
OOCD_TGT = stm32f3.cfg
endif

ifeq ($(TARGET),tiny)
MCU       = cortex-m3
CHIP      = STM32F103xB
BOARD     = F1_TINY
SERIES    = STM32F1

CDEFS    += -DUSE_HAL_DRIVER
CDEFS    += -DSTM32F103xB
CDEFS    += -DHSE_VALUE=8000000UL

HAL_DRV  = STM32F1xx
HAL_DRV2 = stm32f1xx

TGT_SRC  = src/system_stm32f1xx.c 
TGT_SRC += src/stm32f1xx_it.c
TGT_ASRC = gcc/startup_stm32f103xb.s
TGT_LD   = -T./gcc/STM32F103X8_FLASH.ld
OOCD_TGT = stm32f1.cfg
endif

ifeq ($(TARGET),f105)
MCU       = cortex-m3
CHIP      = STM32F105xC
BOARD     = F105_LITE
SERIES    = STM32F1

CDEFS    += -DUSE_HAL_DRIVER
CDEFS    += -DSTM32F105xC
CDEFS    += -DHSE_VALUE=8000000UL

HAL_DRV  = STM32F1xx
HAL_DRV2 = stm32f1xx

TGT_SRC  = src/system_stm32f1xx.c 
TGT_SRC += src/stm32f1xx_it.c
TGT_ASRC = gcc/startup_stm32f105xc.s
TGT_LD   = -T./gcc/STM32F105XB_FLASH.ld
OOCD_TGT = stm32f1.cfg
endif

RUN_MODE=FLASH_RUN
#RUN_MODE=RAM_RUN

VECTOR_TABLE_LOCATION=VECT_TAB_FLASH
#VECTOR_TABLE_LOCATION=VECT_TAB_RAM

OUTDIR = build_$(TARGET)

# List C source files here
SRC  = $(TGT_SRC)
SRC += src/led.c
SRC += src/main.c
SRC += gcc/syscalls.c
SRC += src/uart.c

# enable what you need from HAL:

HAL_PATH = lib/Drivers/$(HAL_DRV)_HAL_Driver/Src/$(HAL_DRV2)

#SRC += $(HAL_PATH)_hal_hcd.c
#SRC += $(HAL_PATH)_ll_usb.c
#SRC += $(HAL_PATH)_hal_spi.c
#SRC += $(HAL_PATH)_hal_i2c.c
SRC += $(HAL_PATH)_hal.c
#SRC += $(HAL_PATH)_hal_adc.c
#SRC += $(HAL_PATH)_hal_adc_ex.c
SRC += $(HAL_PATH)_hal_cortex.c
#SRC += $(HAL_PATH)_hal_dma.c
#SRC += $(HAL_PATH)_hal_dma_ex.c
#SRC += $(HAL_PATH)_hal_flash.c
#SRC += $(HAL_PATH)_hal_flash_ex.c
SRC += $(HAL_PATH)_hal_rcc.c
SRC += $(HAL_PATH)_hal_rcc_ex.c
SRC += $(HAL_PATH)_hal_gpio.c
SRC += $(HAL_PATH)_hal_uart.c
SRC += $(HAL_PATH)_hal_tim.c
SRC += $(HAL_PATH)_hal_tim_ex.c
#SRC += $(HAL_PATH)_hal_i2s.c

# List C source files here which must be compiled in ARM-Mode (no -mthumb).
SRCARM = 

# List Assembler source files here.
ASRC = $(TGT_ASRC)

# List Assembler source files here which must be assembled in ARM-Mode.
ASRCARM  = 

# Place project-specific -D and/or -U options for 
# Assembler with preprocessor here.
ADEFS = 

# List any extra directories to look for include files here.
EXTRAINCDIRS += src
EXTRAINCDIRS += lib/Drivers/$(HAL_DRV)_HAL_Driver/Inc
EXTRAINCDIRS += lib/Drivers/CMSIS/Device/ST/$(HAL_DRV)/Include
EXTRAINCDIRS += lib/Drivers/CMSIS/Include

# List non-source files which should trigger build here
BUILDONCHANGE = Makefile

# List any extra directories to look for library files here.
EXTRA_LIBDIRS =

OPT = 3

# Debugging format.
#DEBUG = stabs
#DEBUG = dwarf-2
DEBUG = gdb

# Compiler flag to set the C Standard level.
CSTANDARD = -std=gnu99

# Flash programming tool
FLASH_TOOL = OPENOCD

# Some warnings can be disabled by this setting 
DISABLESPECIALWARNINGS = no

# ---------------------------------------------------------------------------
# Options for OpenOCD flash-programming
# see openocd.pdf/openocd.texi for further information
#
OOCD_LOADFILE+=$(OUTDIR)/$(TARGET).elf
# if OpenOCD is in the $PATH just set OPENOCDEXE=openocd
OOCD_EXE=openocd
# debug level
OOCD_CL=-d0
#OOCD_CL=-d3
# interface and board/target settings (using the OOCD target-library here)
OOCD_CL+=-f $(OOCD_TGT) 
# initialize
OOCD_CL+=-c init
# if no SRST available:
## why unknown - it's documented... OOCD_CL+=-c "cortex_m3 reset_config sysresetreq"
# commands to prepare flash-write
OOCD_CL+= -c "reset halt"
# show the targets
OOCD_CL+=-c targets
# increase JTAG frequency a little bit - can be disabled for tests
#OOCD_CL+= -c "adapter_khz 1000"
# disable polling (optional)
OOCD_CL+= -c "poll off"
# flash-write and -verify
OOCD_CL+=-c "flash write_image erase $(OOCD_LOADFILE)" -c "verify_image $(OOCD_LOADFILE)"
# AIRCR SYSRESETREQ - workaround since sometimes the controller does not start after reset run
# but seems to "hang" in an NMI - should be removed once cortex_m3 reset_config works
OOCD_CL+=-c"mww 0xE000ED0C 0x05fa0004" -c "sleep 200"
# reset target
OOCD_CL+=-c "reset run"
# show the targets
OOCD_CL+=-c targets
# terminate OOCD after programming
OOCD_CL+=-c shutdown
# ---------------------------------------------------------------------------

OOCD_RESET_CL = openocd -d0 -f $(OOCD_TGT) -c init -c "reset run" -c shutdown

ifdef VECTOR_TABLE_LOCATION
CDEFS += -D$(VECTOR_TABLE_LOCATION)
ADEFS += -D$(VECTOR_TABLE_LOCATION)
endif

CDEFS += -D$(RUN_MODE) -D$(BOARD) -D$(SERIES)
ADEFS += -D$(RUN_MODE) -D$(BOARD) -D$(SERIES)

# Compiler flags.

ifeq ($(USE_THUMB_MODE),YES)
THUMB    = -mthumb
THUMB_IW = -mthumb-interwork
else 
THUMB    = 
THUMB_IW = 
endif

# Flags for C and C++ (arm-elf-gcc/arm-elf-g++)
CFLAGS =  -g$(DEBUG)
CFLAGS += -O$(OPT)
CFLAGS += -mcpu=$(MCU) $(THUMB_IW)
CFLAGS += $(CDEFS)
CFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS)) -I.
# when using ".ramfunc"s without attribute longcall:
#CFLAGS += -mlong-calls
# -mapcs-frame is important if gcc's interrupt attributes are used
# (at least from my eabi tests), not needed if assembler-wrappers are used 

CFLAGS += -mapcs-frame 
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -fstrict-volatile-bitfields
CFLAGS += -Wall  
CFLAGS += -Wpointer-arith
CFLAGS += -Wno-cast-qual
CFLAGS += -Wno-attributes
CFLAGS += -Wa,-adhlns=$(addprefix $(OUTDIR)/, $(notdir $(addsuffix .lst, $(basename $<))))

# Compiler flags to generate dependency files:
CFLAGS += -MMD -MP -MF $(OUTDIR)/dep/$(@F).d

# flags only for C
CONLYFLAGS += -Wnested-externs 
CONLYFLAGS += $(CSTANDARD)

ifeq ($(DISABLESPECIALWARNINGS),yes)
CFLAGS += -Wno-cast-qual
CONLYFLAGS += -Wno-missing-prototypes 
CONLYFLAGS += -Wno-strict-prototypes
CONLYFLAGS += -Wno-missing-declarations
endif

# Assembler flags.
ASFLAGS  = -mcpu=$(MCU) $(THUMB_IW) -I. -x assembler-with-cpp
ASFLAGS += -D__ASSEMBLY__ $(ADEFS)
ASFLAGS += -Wa,-adhlns=$(addprefix $(OUTDIR)/, $(notdir $(addsuffix .lst, $(basename $<))))
ASFLAGS += -Wa,-g$(DEBUG)
ASFLAGS += $(patsubst %,-I%,$(EXTRAINCDIRS))

# Linker flags.
LDFLAGS = -Wl,-Map=$(OUTDIR)/$(TARGET).map,--cref,--gc-sections
LDFLAGS += -lc -lm -lc -lgcc
LDFLAGS += $(CPLUSPLUS_LIB)
LDFLAGS += $(patsubst %,-L%,$(EXTRA_LIBDIRS))
LDFLAGS += $(patsubst %,-L%,$(LINKERSCRIPTINC))
LDFLAGS += $(patsubst %,-l%,$(EXTRA_LIBS)) 
LDFLAGS += $(EXTRA_LDFLAGS)

# Set linker-script name depending on selected run-mode and chip
ifeq ($(RUN_MODE),RAM_RUN)
LDFLAGS +=-T./$(CHIP)_ram.ld
else 
LDFLAGS += $(TGT_LD)
endif

# Autodetect environment
SHELL   = sh
REMOVE_CMD:=rm

# Define programs and commands.
CC      = $(TCHAIN_PREFIX)gcc
AR      = $(TCHAIN_PREFIX)ar
OBJCOPY = $(TCHAIN_PREFIX)objcopy
OBJDUMP = $(TCHAIN_PREFIX)objdump
SIZE    = $(TCHAIN_PREFIX)size
NM      = $(TCHAIN_PREFIX)nm
REMOVE  = $(REMOVE_CMD) -f

      CMD_CC_O_C =  @$(CC) -c $(THUMB) $$(CFLAGS) $$(CONLYFLAGS) $$< -o $$@
quiet_CMD_CC_O_C = "[CC] $$<"

      CMD_AS_T_O_S =  @$(CC) -c $(THUMB) $$(ASFLAGS) $$< -o $$@
quiet_CMD_AS_T_O_S = "[AS] $$<"

      CMD_AS_O_S =  @$(CC) -c $$(ASFLAGS) $$< -o $$@
quiet_CMD_AS_O_S = "[AS] $$<"

      CMD_LD     =  @$(CC) $(THUMB) $(CFLAGS) $(ALLOBJ) --output $@  $(LDFLAGS)
quiet_CMD_LD     = "[LD] $@"

# Define Messages
MSG_COMPILING    = [CC]
MSG_ASSEMBLING   = [AS]
MSG_LINKING      = [LD]
MSG_SYMBOL_TABLE = [SY]
MSG_LISTING      = [LS]
MSG_LOAD_FILE    = [HX]
MSG_SIZE_AFTER   = [Size after build]
MSG_CLEANING     = [Cleaning project]

# List of all source files.
ALLSRC     = $(ASRCARM) $(ASRC) $(SRCARM) $(SRC)
# List of all source files without directory and file-extension.
ALLSRCBASE = $(notdir $(basename $(ALLSRC)))

# Define all object files.
ALLOBJ     = $(addprefix $(OUTDIR)/, $(addsuffix .o, $(ALLSRCBASE)))

# Define all listing files (used for make clean).
LSTFILES   = $(addprefix $(OUTDIR)/, $(addsuffix .lst, $(ALLSRCBASE)))
# Define all depedency-files (used for make clean).
DEPFILES   = $(addprefix $(OUTDIR)/dep/, $(addsuffix .o.d, $(ALLSRCBASE)))

# Default target.
all: build

elf: $(OUTDIR)/$(TARGET).elf
lst: $(OUTDIR)/$(TARGET).lst 
sym: $(OUTDIR)/$(TARGET).sym
hex: $(OUTDIR)/$(TARGET).hex
bin: $(OUTDIR)/$(TARGET).bin

# Target for the build-sequence.
build: elf lst sym

# Display sizes of sections.
ELFSIZE = $(SIZE) -A  $(OUTDIR)/$(TARGET).elf

sizeafter:
	@echo $(MSG_SIZE_AFTER)
	$(ELFSIZE)

p: program

r: reset

# Program the device with Dominic Rath's OPENOCD in "batch-mode"
program: build
	@echo "Programming with OPENOCD"
	-$(OOCD_EXE) $(OOCD_CL)

reset: 
	@echo "RESET!"
	-$(OOCD_EXE) $(OOCD_RESET_CL)

# Create final output file in ihex format from ELF output file (.hex).
%.hex: %.elf
	@echo $(MSG_LOAD_FILE) $@
	$(OBJCOPY) -O ihex $< $@
	
# Create final output file in raw binary format from ELF output file (.bin)
%.bin: %.elf
	@echo $(MSG_LOAD_FILE) $@
	$(OBJCOPY) -O binary $< $@

# Create extended listing file/disassambly from ELF output file.
# using objdump (testing: option -C)
%.lst: %.elf
	@echo $(MSG_LISTING) $@
	@$(OBJDUMP) -h -S -C -r $< > $@

# Create a symbol table from ELF output file.
%.sym: %.elf
	@echo $(MSG_SYMBOL_TABLE) $@
	@$(NM) -n $< > $@

# Link: create ELF output file from object files.
.SECONDARY : $(TARGET).elf
.PRECIOUS : $(ALLOBJ)
%.elf:  $(ALLOBJ) $(BUILDONCHANGE)
	@echo $($(quiet)CMD_LD)
	@$(CMD_LD)

# Assemble: create object files from assembler source files.
define ASSEMBLE_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@mkdir -p $(OUTDIR)
	@mkdir -p $(OUTDIR)/dep
	@echo $($(quiet)CMD_AS_T_O_S)
	@$(CMD_AS_T_O_S)
endef
$(foreach src, $(ASRC), $(eval $(call ASSEMBLE_TEMPLATE, $(src)))) 

# Assemble: create object files from assembler source files. ARM-only
define ASSEMBLE_ARM_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@echo $($(quiet)CMD_AS_O_S)
	@$(CMD_AS_O_S)
endef
$(foreach src, $(ASRCARM), $(eval $(call ASSEMBLE_ARM_TEMPLATE, $(src)))) 

# Compile: create object files from C source files.
define COMPILE_C_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@mkdir -p $(OUTDIR)
	@echo $($(quiet)CMD_CC_O_C)
	@$(CMD_CC_O_C)
endef
$(foreach src, $(SRC), $(eval $(call COMPILE_C_TEMPLATE, $(src)))) 

# Compile: create object files from C source files. ARM-only
define COMPILE_C_ARM_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@echo $(MSG_COMPILING) $$<
	@$(CC) -c $$(CFLAGS) $$(CONLYFLAGS) $$< -o $$@ 
endef
$(foreach src, $(SRCARM), $(eval $(call COMPILE_C_ARM_TEMPLATE, $(src)))) 

# Compile: create object files from C++ source files.
define COMPILE_CPP_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@echo $(MSG_COMPILING) $$<
	@$(CC) -c $(THUMB) $$(CFLAGS) $$(CPPFLAGS) $$< -o $$@ 
endef
$(foreach src, $(CPPSRC), $(eval $(call COMPILE_CPP_TEMPLATE, $(src)))) 

# Compile: create object files from C++ source files. ARM-only
define COMPILE_CPP_ARM_TEMPLATE
$(OUTDIR)/$(notdir $(basename $(1))).o : $(1) $(BUILDONCHANGE)
	@echo $(MSG_COMPILING) $$<
	@$(CC) -c $$(CFLAGS) $$(CPPFLAGS) $$< -o $$@ 
endef
$(foreach src, $(CPPSRCARM), $(eval $(call COMPILE_CPP_ARM_TEMPLATE, $(src)))) 

# Target: clean project.
clean:
	@echo $(MSG_CLEANING)
	$(REMOVE) $(OUTDIR)/$(TARGET).map
	$(REMOVE) $(OUTDIR)/$(TARGET).elf
	$(REMOVE) $(OUTDIR)/$(TARGET).hex
	$(REMOVE) $(OUTDIR)/$(TARGET).bin
	$(REMOVE) $(OUTDIR)/$(TARGET).sym
	$(REMOVE) $(OUTDIR)/$(TARGET).lst
	$(REMOVE) $(ALLOBJ)
	$(REMOVE) $(LSTFILES)
	$(REMOVE) $(DEPFILES)
	$(REMOVE) $(SRC:.c=.s)
	$(REMOVE) $(SRCARM:.c=.s)
	$(REMOVE) $(CPPSRC:.cpp=.s)
	$(REMOVE) $(CPPSRCARM:.cpp=.s)

allclean: clean
	$(REMOVE) -r ./build_*

# Include the dependency files.
-include $(wildcard $(OUTDIR)/dep/*.d)

# Listing of phony targets.
.PHONY : all sizeafter gccversion build elf hex bin lst sym clean clean_list program

