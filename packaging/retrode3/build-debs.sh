#!/usr/bin/env bash
# Source-built X1600 SPL/U-Boot Debian candidate: NEVER flash a running device.
set -euo pipefail
[[ "$#" == 2 && "$1" == /* ]] || { echo "Usage: $0 /abs/output version" >&2; exit 2; }
out="$1"; version="$2"
[[ "$version" =~ ^[0-9][A-Za-z0-9.+:~_-]*$ ]] || exit 1
src="$(cd "$(dirname "$0")/../.." && pwd -P)"
test "$(mipsel-linux-gnu-gcc -dumpmachine)" = mipsel-linux-gnu
mkdir -p "$out"
# Clone/pin sources in the parent orchestrator; this recipe uses the exact
# checkout at that commit and never installs to the buildserver's disk.
make -C "$src" CROSS_COMPILE=mipsel-linux-gnu- lx16_uImage_msc0
make -C "$src" CROSS_COMPILE=mipsel-linux-gnu- -j2
for file in u-boot-with-spl-mbr-gpt.bin spl/u-boot-spl.bin u-boot.bin; do
  test -s "$src/$file" || { echo "Missing U-Boot $file" >&2; exit 1; }
done
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
pkg="$tmp/root"
dst="$pkg/usr/lib/retrode3/bootloader-candidates/x1600/$version"
mkdir -p "$pkg/DEBIAN" "$dst/spl"
cp "$src/u-boot-with-spl-mbr-gpt.bin" "$dst/"
cp "$src/spl/u-boot-spl.bin" "$dst/spl/"
cp "$src/u-boot.bin" "$dst/"
cat > "$pkg/DEBIAN/control" <<EOF
Package: retrode3-uboot-x1600
Version: $version
Architecture: mipsel
Section: admin
Priority: optional
Maintainer: OpenPandora GmbH <info@openpandora.org>
Description: Retrode3 Ingenic X1600 SPL and U-Boot candidate
 Bootloader files are staged for offline image assembly only.
 The package never writes MMC boot sectors or replaces active firmware.
EOF
deb="$out/retrode3-uboot-x1600_${version}_mipsel.deb"
[[ ! -e "$deb" ]] || exit 1
dpkg-deb --root-owner-group --build "$pkg" "$deb"
echo "U-Boot X1600 candidate $version ready"
