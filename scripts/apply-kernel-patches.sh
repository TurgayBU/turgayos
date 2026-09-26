#!/bin/bash
# Apply TurgayOS kernel modifications to Buildroot's kernel build directory.
# Idempotent: safe to run multiple times.
#
# Usage: ./scripts/apply-kernel-patches.sh

set -e

KERNEL_DIR="$HOME/buildroot/output/build/linux-6.18.7"
PATCHES_DIR="$(cd "$(dirname "$0")/../kernel-patches" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================"
echo "  TurgayOS Kernel Patch Applier"
echo "========================================"
echo ""

if [ ! -d "$KERNEL_DIR" ]; then
    echo -e "${RED}[!] Kernel directory not found:${NC} $KERNEL_DIR"
    echo -e "${YELLOW}[*] Run 'cd ~/buildroot && make' first to unpack the kernel.${NC}"
    exit 1
fi

cd "$KERNEL_DIR"

echo -e "${YELLOW}[1/4]${NC} Adding syscall #548 to syscall_64.tbl..."
if grep -q "hello_kernel" arch/x86/entry/syscalls/syscall_64.tbl; then
    echo -e "      ${GREEN}✓${NC} Already present, skipping"
else
    echo "548	common	hello_kernel	sys_hello_kernel" >> arch/x86/entry/syscalls/syscall_64.tbl
    echo -e "      ${GREEN}✓${NC} Added"
fi

echo -e "${YELLOW}[2/4]${NC} Declaring sys_hello_kernel in syscalls.h..."
if grep -q "sys_hello_kernel" include/linux/syscalls.h; then
    echo -e "      ${GREEN}✓${NC} Already present, skipping"
else
    sed -i 's|^#endif /\* _LINUX_SYSCALLS_H \*/|asmlinkage long sys_hello_kernel(void);\n\n#endif /* _LINUX_SYSCALLS_H */|' include/linux/syscalls.h
    echo -e "      ${GREEN}✓${NC} Declared"
fi

echo -e "${YELLOW}[3/4]${NC} Copying hello.c implementation..."
cp "$PATCHES_DIR/hello.c" kernel/hello.c
echo -e "      ${GREEN}✓${NC} Copied"

echo -e "${YELLOW}[4/4]${NC} Adding hello.o to kernel/Makefile..."
if grep -q "hello.o" kernel/Makefile; then
    echo -e "      ${GREEN}✓${NC} Already present, skipping"
else
    echo "obj-y += hello.o" >> kernel/Makefile
    echo -e "      ${GREEN}✓${NC} Added"
fi

echo ""
echo "========================================"
echo -e "  ${GREEN}All modifications applied!${NC}"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. cd ~/buildroot && make linux-rebuild"
echo "  2. ~/turgayos/scripts/run-qemu.sh"
echo "  3. Inside guest: cat /proc/kallsyms | grep hello_kernel"
