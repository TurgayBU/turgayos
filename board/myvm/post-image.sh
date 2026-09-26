#!/bin/sh
set -e

BINARIES_DIR="$1"

cp board/myvm/grub.cfg ${BINARIES_DIR}/

rm -rf /tmp/genimage.tmp

genimage \
  --rootpath "${TARGET_DIR}" \
  --tmppath /tmp/genimage.tmp \
  --inputpath "${BINARIES_DIR}" \
  --outputpath "${BINARIES_DIR}" \
  --config board/myvm/genimage.cfg
