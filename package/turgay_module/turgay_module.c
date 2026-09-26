#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

static int __init turgay_init(void)
{
    printk(KERN_INFO "turgay_module: Hello, kernel module has uploaded!\n");
    return 0;
}

static void __exit turgay_exit(void)
{
    printk(KERN_INFO "turgay_module: Bye bye, module has deleted!\n");
}

module_init(turgay_init);
module_exit(turgay_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Turgay Bozoglu");
MODULE_DESCRIPTION("A basic Buildroot kernel module");
