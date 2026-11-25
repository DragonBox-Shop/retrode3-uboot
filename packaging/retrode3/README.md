# Retrode3 X1600 SPL/U-Boot Debian package

The authoritative source is this repository's `develop` line, derived
from Letux `ingenic-x1600-v5`; old `master` is NOT a Retrode3
production board configuration.

`bash packaging/retrode3/build-debs.sh /absolute/output version`
crossbuilds the `lx16_uImage_msc0` board target and stages the SPL,
combined loader image and U-Boot binary in the versioned
`retrode3-uboot-x1600` candidate Debian package.

Installing the package must NEVER write raw MMC sectors or overwrite
the currently running loader. Only the offline SD image assembler or
a separately audited, rollback-aware activation tool may use these
candidate bytes. The assembler verifies the raw SPL offsets and strips
old vendor GPT metadata before writing a DOS-partitioned SD image.

The central buildserver pins source Git commits and compiler image
identity; developer changes/pushes happen on a workstation, never on
Amaterasu. A full cold boot from a spare SD is required before release.
