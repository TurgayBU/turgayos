################################################################################
#
# turgay_module
#
################################################################################

TURGAY_MODULE_VERSION = 1.0
TURGAY_MODULE_SOURCE = turgay_module-1.0.tar.gz
TURGAY_MODULE_SITE = $(TOPDIR)/package/turgay_module/src
TURGAY_MODULE_SITE_METHOD = local

TURGAY_MODULE_LICENSE = GPL-2.0
TURGAY_MODULE_LICENSE_FILES = turgay_module.c

$(eval $(kernel-module))
$(eval $(generic-package))
