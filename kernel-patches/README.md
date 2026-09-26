# Kernel Modifications for TurgayOS

This directory documents all modifications made to **Linux kernel 6.18.7**
to add the custom `hello_kernel` system call (syscall **#548**).

---

## Why no `.patch` files?

Buildroot unpacks the kernel tarball into `output/build/linux-6.18.7/`,
which is **not a git repository**. Therefore, `git diff` cannot be used
to generate patches automatically.

Instead, this README documents the exact modifications required. Use the
helper script `scripts/apply-kernel-patches.sh` to apply them after
Buildroot has unpacked the kernel.

---

## Modifications Summary

| # | File | Change |
|---|------|--------|
| 1 | `arch/x86/entry/syscalls/syscall_64.tbl` | Add syscall entry #548 |
| 2 | `include/linux/syscalls.h` | Declare `sys_hello_kernel()` |
| 3 | `kernel/hello.c` | Implement the syscall (new file) |
| 4 | `kernel/Makefile` | Add `obj-y += hello.o` |

---

## Detailed Changes

### 1. Register syscall #548

**File:** `arch/x86/entry/syscalls/syscall_64.tbl`

**Action:** Append after syscall 547 (`futex_wake`):

```
548	common	hello_kernel	sys_hello_kernel
```

**Verify:**

```bash
grep hello_kernel ~/buildroot/output/build/linux-6.18.7/arch/x86/entry/syscalls/syscall_64.tbl
```

---

### 2. Declare the function

**File:** `include/linux/syscalls.h`

**Action:** Add before the final `#endif`:

```c
asmlinkage long sys_hello_kernel(void);
```

---

### 3. Implement the syscall

**File:** `kernel/hello.c` (new file, provided in this directory)

```c
#include <linux/kernel.h>
#include <linux/syscalls.h>

SYSCALL_DEFINE0(hello_kernel)
{
    printk(KERN_EMERG "!!! HELLO FROM KERNEL !!!\n");
    return 0;
}
```

**Explanation:**

- `SYSCALL_DEFINE0(name)` — Defines a syscall with 0 arguments
- `printk(KERN_EMERG ...)` — Prints to kernel log buffer at emergency level
- Returns `0` to indicate success to user space

---

### 4. Register the object file

**File:** `kernel/Makefile`

**Action:** Add to the `obj-y` list:

```makefile
obj-y += hello.o
```

---

## How to Apply

### Automated (recommended)

```bash
~/turgayos/scripts/apply-kernel-patches.sh
cd ~/buildroot && make linux-rebuild
```

### Manual

```bash
cd ~/buildroot/output/build/linux-6.18.7

# 1. Add syscall to table
echo "548	common	hello_kernel	sys_hello_kernel" >> arch/x86/entry/syscalls/syscall_64.tbl

# 2. Add declaration
sed -i 's|^#endif /\* _LINUX_SYSCALLS_H \*/|asmlinkage long sys_hello_kernel(void);\n\n#endif /* _LINUX_SYSCALLS_H */|' include/linux/syscalls.h

# 3. Copy implementation
cp ~/turgayos/kernel-patches/hello.c kernel/hello.c

# 4. Add to Makefile
echo "obj-y += hello.o" >> kernel/Makefile

# 5. Rebuild
cd ~/buildroot && make linux-rebuild
```

---

## Verification After Boot

Boot TurgayOS and run:

```bash
cat /proc/kallsyms | grep hello_kernel
```

**Expected:**

```
ffffffff82a07a10 t __pfx__do_sys_hello_kernel
ffffffff82a07a10 T __pfx__x64_sys_hello_kernel
ffffffff82a07a20 t __do_sys_hello_kernel
ffffffff82a07a20 T __x64_sys_hello_kernel
```

Then run the user-space test:

```bash
hi
# Expected: ✓ SUCCESS! Hello from kernel!
```

---

## How It Works — Under the Hood

When user space calls `syscall(548)`:

1. **User space:** `syscall(SYS_HELLO_KERNEL)` is invoked
2. **CPU:** `syscall` instruction switches ring 3 → ring 0
3. **Kernel:** Looks up `sys_call_table[548]` → `__x64_sys_hello_kernel`
4. **Kernel:** Executes `printk(...)` → writes to kernel log buffer
5. **Kernel:** Returns `0` in `rax`
6. **CPU:** `sysret` switches back to ring 3
7. **User space:** `ret == 0`, prints success message

---

## References

- [Linux Kernel Syscall Documentation](https://www.kernel.org/doc/html/latest/process/adding-syscalls.html)
- [x86_64 Syscall Table](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl)
