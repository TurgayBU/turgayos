# TurgayOS — Buildroot-Based Custom Linux OS

A fully functional, personalized x86_64 Linux operating system built from
scratch with **Buildroot**, featuring a custom kernel, custom system call,
custom kernel module, and a suite of BusyBox-compatible user-space utilities.

![Status](https://img.shields.io/badge/status-working-brightgreen)
![Platform](https://img.shields.io/badge/platform-x86__64-blue)
![Kernel](https://img.shields.io/badge/kernel-6.18.7-yellow)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## 📦 Prebuilt Disk Image

Don't want to build from source? Download the prebuilt `disk.img` (~80 MB)
from [Releases](https://github.com/TurgayBU/turgayos/releases).

**Boot it in QEMU:**

```bash
qemu-system-x86_64 \
    -drive file=disk.img,format=raw \
    -netdev user,id=net0 \
    -device e1000,netdev=net0 \
    -nographic
```

**Login:** `root` / `turgay`

---

## Features

- **Custom Linux Kernel** (6.18.7) — configured with e1000, virtio_net, PCI, PHY/MII
- **Custom System Call** — `hello_kernel` (syscall #548)
- **Custom Kernel Module** — `turgay_module` packaged as a Buildroot package
- **9 User-Space Utilities** — `whoami-plus`, `netcheck`, `bootlog`, `sysinfo`, `safe-reboot`, `net-enable`, `net-disable`, `net-status`, `hi`
- **Bootable Disk Image** — GPT-partitioned `disk.img` with GRUB2 bootloader
- **Custom Boot Banner** — ASCII art in `/etc/issue`
- **Kernel Boot Parameter** — `turgay_debug=1` in `/proc/cmdline`
- **Dual Emulation Support** — QEMU (x86_64 native) + UTM (x86_64 on Apple Silicon)
- **Root Filesystem Overlay** — all customizations survive rebuilds

---

## Architecture

```
Development Host:  macOS (Apple Silicon ARM64)
    └── VirtualBox 7.2.6
        └── Ubuntu 24.04.4 LTS (ARM64)  ← Build VM
            └── Buildroot 2026.05-git
                └── Cross-compile → x86_64 target

Test Environment:
    ├── QEMU (x86_64 native)
    └── UTM (x86_64 emulation on Apple Silicon)
```

---

## Project Structure

```
turgayos/
├── README.md
├── LICENSE
├── .gitignore
├── board/
│   ├── myvm/                          # GRUB + genimage config
│   └── turgay/myos/rootfs-overlay/    # Root filesystem overlay
├── configs/
│   ├── turgayos_defconfig             # Buildroot config
│   └── linux_turgayos_defconfig       # Kernel config
├── kernel-patches/
│   ├── README.md                      # Documents kernel changes
│   └── hello.c                        # Custom syscall implementation
├── package/
│   └── turgay_module/                 # Custom Buildroot package
└── scripts/
    ├── apply-kernel-patches.sh
    └── run-qemu.sh
```

---

## Quick Start

### Prerequisites (Ubuntu build VM)

```bash
sudo apt install -y git build-essential bison flex libncurses-dev \
    libssl-dev bc unzip wget cpio rsync python3 gawk \
    qemu-system-x86 genimage mtools
```

### Build

```bash
# 1. Clone Buildroot
git clone https://gitlab.com/buildroot.org/buildroot.git
cd buildroot

# 2. Load base config
make qemu_x86_64_defconfig

# 3. Copy TurgayOS files
cp -r ~/turgayos/board/* board/
cp -r ~/turgayos/package/* package/
cp ~/turgayos/configs/turgayos_defconfig .config

# 4. Apply kernel modifications
~/turgayos/scripts/apply-kernel-patches.sh

# 5. Build
make -j"$(nproc)"

# 6. Boot
~/turgayos/scripts/run-qemu.sh
```

**Login:** `root` / `changeme` (change it in the config before building!)

### Boot in QEMU (manual)

```bash
qemu-system-x86_64 \
    -drive file=output/images/disk.img,format=raw \
    -netdev user,id=net0 \
    -device e1000,netdev=net0 \
    -nographic
```

---

## Custom Utilities

| Command | Description |
|---------|-------------|
| `whoami-plus` | User + hostname + uptime + IP |
| `netcheck` | Network diagnostic (IP, gateway, ping) |
| `bootlog` | Recent kernel boot messages |
| `sysinfo` | Minimal neofetch-like system summary |
| `safe-reboot` | Controlled reboot with countdown |
| `net-enable` | Load network driver module |
| `net-disable` | Unload network driver module |
| `net-status` | Show network driver status |
| `hi` | Test the custom system call |

---

## Kernel Customizations

### 1. Custom System Call: `hello_kernel` (syscall #548)

See [kernel-patches/README.md](kernel-patches/README.md) for full details.

**Implementation** (`kernel/hello.c`):

```c
#include <linux/kernel.h>
#include <linux/syscalls.h>

SYSCALL_DEFINE0(hello_kernel)
{
    printk(KERN_EMERG "!!! HELLO FROM KERNEL !!!\n");
    return 0;
}
```

**Test:**

```bash
root@TurgayOS:~# hi
!!! HELLO FROM KERNEL !!!
✓ SUCCESS! Hello from kernel!
```

### 2. Custom Kernel Module: `turgay_module`

Packaged as a Buildroot package under `package/turgay_module/`.

**Test:**

```bash
root@TurgayOS:~# modprobe turgay_module
turgay_module: Hello, kernel module has uploaded!
root@TurgayOS:~# rmmod turgay_module
turgay_module: Bye bye, module has deleted!
```

### 3. Custom Kernel Boot Parameter

`turgay_debug=1` added via `make linux-menuconfig` → *Processor type and
features* → *Built-in kernel command line*.

```bash
root@TurgayOS:~# cat /proc/cmdline
root=/dev/sda console=ttyS0 turgay_debug=1
```

---

## Testing & Validation

| Test | Tool | Result |
|------|------|--------|
| Boot to login | QEMU / UTM | ✅ |
| DHCP IP acquisition | `udhcpc` | ✅ |
| Ping gateway | `ping` | ✅ 0% loss |
| Custom syscall | `hi` | ✅ |
| Kernel module load/unload | `modprobe` / `rmmod` | ✅ |
| Boot parameter | `cat /proc/cmdline` | ✅ |
| All 9 user scripts | manual | ✅ |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `command: not found` after adding script | `hash -r` or `exec sh` |
| `timeout!` during network init | Enable e1000 + PHY/MII in kernel config |
| GRUB `PARTUUID` not found | Patch `grub.cfg` to `root=/dev/sda2` |
| VirtualBox UUID mismatch | Use a **new** VDI filename each conversion |
| Module version magic mismatch | Rebuild module against same kernel version |

---

## 📄 Full Report

A complete **242-page engineering report** documenting the entire project:

- Project methodology and development environment
- Step-by-step Buildroot configuration
- Kernel customizations with screenshots
- Custom syscall and kernel module implementation
- Troubleshooting notes and lessons learned

**Download:** [Turgay_Bozoglu.pdf](https://github.com/TurgayBU/turgayos/releases/download/v1.0/Turgay_Bozoglu.pdf) (~48 MB)

---

## 📜 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

You are free to use, modify, and distribute this project for any purpose,
provided that the original copyright notice and license are included.

### Third-Party Components

This project builds upon and includes several open-source components.
Their respective licenses are listed below:

| Component | License | Source | Notes |
|-----------|---------|--------|-------|
| **Linux Kernel 6.18.7** | GPL-2.0 | [kernel.org](https://www.kernel.org/) | Modified (custom syscall added). See [`kernel-patches/`](kernel-patches/) for all changes. Full source available at [git.kernel.org](https://git.kernel.org/). |
| **Buildroot 2026.05-git** | GPL-2.0 | [buildroot.org](https://buildroot.org/) | Used **unmodified** as a build framework. |
| **BusyBox** | GPL-2.0 | [busybox.net](https://busybox.net/) | Included in the root filesystem. |
| **GRUB2** | GPL-3.0 | [gnu.org/software/grub](https://www.gnu.org/software/grub/) | Bootloader used in `disk.img`. |
| **`turgay_module.c`** | GPL-2.0 | This repository | Kernel module — GPL-2.0 required for kernel compatibility. |
| **Custom user-space scripts** | MIT | This repository | `whoami-plus`, `netcheck`, `sysinfo`, etc. |
| **Prebuilt `disk.img`** | Aggregated | This repository | Contains Linux + Buildroot + custom components. See individual licenses above. |

### Important Notes

- **Linux-syscall-note:** The Linux kernel provides an explicit exception
  ([COPYING](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/COPYING))
  stating that user-space programs using the system call interface are **not**
  considered derivative works and may be licensed under any terms. This means
  the user-space utilities in this project (MIT-licensed) can freely use
  syscall #548 without GPL implications.

- **Kernel patches:** All modifications made to the Linux kernel are documented
  and released under **GPL-2.0** in [`kernel-patches/`](kernel-patches/),
  fully complying with the kernel's licensing requirements.

- **No commercial intent:** This project was developed as an academic exercise
  and portfolio piece. It is not intended for commercial distribution.

- **Redistribution:** If you redistribute this project or a derivative work,
  you must comply with all applicable licenses (MIT for this project's original
  code, GPL-2.0 for kernel-related code, GPL-3.0 for GRUB2, etc.).

---

## Acknowledgments

- **Oruç Raif Önvural** — Operating Systems course instructor, Beykoz University
- **Buildroot** — the build framework that made this possible
- **DeepSeek** — AI assistant for code review and documentation formatting
  (all engineering decisions and final validation were performed by the author)

---

## Contact

**Turgay Bozoğlu** — Beykoz University, Computer Engineering

- GitHub: [@TurgayBU](https://github.com/TurgayBU)
