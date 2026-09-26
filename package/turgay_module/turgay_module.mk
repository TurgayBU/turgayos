################################################################################
#
# turgay_module
#
################################################################################

TURGAY_MODULE_VERSION = 1.0
TURGAY_MODULE_SOURCE = turgay_module-1.0.tar.gz
TURGAY_MODULE_SITE = file:///home/turgay

TURGAY_MODULE_LICENSE = GPL-3.0
TURGAY_MODULE_LICENSE_FILES = LICENSE

$(eval $(kernel-module))
$(eval $(generic-package))
