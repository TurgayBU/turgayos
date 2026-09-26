#!/bin/bash
# Boot TurgayOS in QEMU with e1000 networking
# Usage: ./scripts/run-qemu.sh [path/to/disk.img]

set -e

DISK_IMG="${1:-$HOME/buildroot/output/images/disk.img}"

if [ ! -f "$DISK_IMG" ]; then
    echo "[!] Disk image not found: $DISK_IMG"
    echo "[*] Build first: cd ~/buildroot && make"
    exit 1
fi

echo "======================================"
echo "  Booting TurgayOS in QEMU"
echo "======================================"
echo "  Disk: $DISK_IMG"
echo "  Networking: user-mode NAT + e1000"
echo "  Console: serial (nographic)"
echo ""
echo "  Login: root / turgay"
echo "  Exit QEMU: Ctrl+A then X"
echo "======================================"
echo ""

qemu-system-x86_64 \
    -drive file="$DISK_IMG",format=raw \
    -netdev user,id=net0 \
    -device e1000,netdev=net0 \
    -nographic
