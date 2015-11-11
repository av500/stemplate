# stemplate
STM32 template project

targets supported:

wifi: 	EMW3165 STM32F411 based WiFi module

disco: 	STM32F407 Discovery

tiny: 	various STM32F103 based modules from eBay

f105: 	STM32F105 based module from 36board

----------------------

To compile and rund this code you need the following:

1) Toolchain

Download and unzip the toolchain at:

https://launchpad.net/gcc-arm-embedded/+download
Add the PATH to the compile to your PATH variable, e.g.

export PATH=$PATH:/opt/gcc-arm-none-eabi-4_9-2014q4/arm-none-eabi/bin/
2) OpenOCD

To flash the SW to the CPU/module you need to install openOCD and make sure it's in the PATH. you need an STLINK or compatible SWD debugger, edit stm32fx.cfg to switch from v2.1 to v.2.

3) Building

To build, simply type

TARGET=<target> make
which will build the project in the build_/ folder

To program the board, use

TARGET=<target> make p (or TARGET=<target> make program)
