#include <linux/kernel.h>
#include <linux/syscalls.h>

SYSCALL_DEFINE0(hello_kernel)
{
    printk(KERN_EMERG "!!! HELLO FROM KERNEL !!!\n");
    return 0;
}
