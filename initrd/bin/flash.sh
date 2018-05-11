#!/bin/sh
#
# based off of flashrom-x230
#
set -e -o pipefail
. /etc/functions
. /etc/config

case "$CONFIG_BOARD" in
  librem* )
    FLASHROM_OPTIONS='-p internal:laptop=force_I_want_a_brick,ich_spi_mode=hwseq' 
  ;;
  "x230" )
    FLASHROM_OPTIONS='--force --noverify-all --programmer internal --ifd --image bios'
  ;;
  "kgpe-d16" )
    FLASHROM_OPTIONS='--force --noverify --programmer internal'
  ;;
  "kgpe-d16-openbmc" )
    FLASHROM_OPTIONS='--programmer="ast1100:spibus=2,cpu=reset" -c "S25FL128P......0"'
  ;;
  * )
    die "ERROR: No board has been configured!\n\nEach board requires specific flashrom options and it's unsafe to flash without them.\n\nAborting."
  ;;
esac

flash_rom() {
  ROM=$1
  cp "$ROM" /tmp/${CONFIG_BOARD}.rom
  sha256sum /tmp/${CONFIG_BOARD}.rom
  if [ "$CLEAN" -eq 0 ]; then
    preserve_rom /tmp/${CONFIG_BOARD}.rom \
    || die "$ROM: Config preservation failed"
  fi

  flashrom $FLASHROM_OPTIONS -w /tmp/${CONFIG_BOARD}.rom \
  || die "$ROM: Flash failed"
}

if [ "$1" = "-c" ]; then
  CLEAN=1
  ROM="$2"
else
  CLEAN=0
  ROM="$1"
fi

if [ ! -e "$ROM" ]; then
	die "Usage: $0 [-c] <path_to_image.rom>"
fi

flash_rom $ROM
exit 0
