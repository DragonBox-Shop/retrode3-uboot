# Retrode3 U-Boot source and upstream tracking

This fork follows https://github.com/goldelico/letux-uboot.
The important source branch is **ingenic-x1600-v5** (not upstream master).
The relevant build target is **lx16_uImage_msc0** (MIPS X1600, MMC0).
The original imported SHA is b40dada8f20227e34b4cc6d341dee806eaf5d62a.

## Branches

- ingenic-x1600-v5: original Letux branch, preserved.
- upstream/letux-x1600-v5: isolated automatic mirror, only branch updated nightly.
- develop: our Retrode3 development branch, based on X1600 v5.
- master: currently the old upstream default, **NOT yet a Retrode3 release**.

Do not automatically merge upstream into develop or master. Retain the
original Letux source history and promote U-Boot only after board testing.

## GitHub Actions schedule

Workflow: .github/workflows/sync-letux-x1600.yml.
Every night at 03:47 UTC, plus a manual workflow_dispatch.
The workflow runs from the current default branch master, where it is
installed, and is duplicated on develop for a later default-branch change.
It fetches the public ingenic-x1600-v5 branch from goldelico/letux-uboot.
Only upstream/letux-x1600-v5 is pushed, with a force-with-lease guard.
Changes create a GitHub issue with file and revision comparison,
not an automatic PR or merge. Initial mirror creation is silent.

Forks may have GitHub Actions disabled until enabled manually.
Check Settings > Actions for workflow permissions. The GITHUB_TOKEN
requires repository contents:write and issues:write, which the YAML requests.
Run the workflow once manually from Actions to verify its first execution.
Neither the YAML alone nor the pre-created matching mirror proves that
the schedule has run.

## Using source-built U-Boot in the image builder

Board code is under board/letux/letux-x16 and include/configs/letux-x16.h.
Relevant outputs include u-boot-with-spl.bin and
u-boot-with-spl-mbr-gpt.bin. Do not blindly use the latter: it can carry
legacy partition metadata which conflict with our FAT/ext4 image.
First compare the generated SPL, offsets, DDR parameters and environment
with the known-working SD's 1 MiB preboot dump. Keep that checksum-pinned
donor as a fallback until a separate SD boots the source-built U-Boot.
Stable master can only be considered ready after this hardware test.
