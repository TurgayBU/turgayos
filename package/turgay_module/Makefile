obj-m := turgay_module.o

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD := $(shell pwd)

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules   # ← TAB karakteri!

clean:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean     # ← TAB karakteri!
