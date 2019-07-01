inherit kernel-resin deploy

FILESEXTRAPATHS_append := ":${THISDIR}/${PN}"

# Prevent delayed booting
SRC_URI_append = " \
    file://0001-revert-random-fix-crng_ready-test.patch \
    file://0001-Support-referencing-the-root-partition-label-from-GP.patch \
"

TEGRA_INITRAMFS_INITRD = "0"

RESIN_CONFIGS_append_jetson-nano = " tegra-wdt-t21x"
RESIN_CONFIGS[tegra-wdt-t21x] = " \
    CONFIG_TEGRA21X_WATCHDOG=m \
"

# Switch some default built-in tegra configs
# to modules to shrink kernel below
# 40MB
RESIN_CONFIGS_append = " unused"
RESIN_CONFIGS[unused] = " \
    CONFIG_AUTOFS4_FS=m \
    CONFIG_EXT3_FS=m \
    CONFIG_NETWORK_FILESYSTEMS=m \
    CONFIG_NFS_FS=m \
    CONFIG_NFS_V2=m \
    CONFIG_NFS_V3=m \
    CONFIG_ROOT_NFS=n \
    CONFIG_NFSD_V2_ACL=n \
    CONFIG_NFSD_V3=n \
    CONFIG_NFSD_V3_ACL=n \
    CONFIG_HAVE_DEBUG_KMEMLEAK=n \
    CONFIG_DEBUG_KMEMLEAK=n \
    CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF=y \
    CONFIG_DEBUG_KMEMLEAK_SCAN_ON=n \
"

KERNEL_ROOTSPEC_jetson-nano = "\${resin_kernel_root} ro rootwait"
KERNEL_ROOTSPEC_jetson-tx2 = " \${resin_kernel_root} ro rootwait sdhci_tegra.en_boot_part_access=1"

# Since 32.1 on tx2, after kernel is loaded sd card becomes mmcblk2 opposed
# to u-boot where it was 1. This is another cause of failure of
# previous flasher images.  Use label to distinguish rootfs
KERNEL_ROOTSPEC_FLASHER = " root=LABEL=flash-rootA ro rootwait sdhci_tegra.en_boot_part_access=1 flasher"

generate_extlinux_conf() {
    install -d ${D}/${KERNEL_IMAGEDEST}/extlinux
    rm -f ${D}/${KERNEL_IMAGEDEST}/extlinux/extlinux.conf
    rm -f ${D}/${KERNEL_IMAGEDEST}/extlinux/extlinux.conf_flasher
    kernelRootspec="${KERNEL_ROOTSPEC}" ; cat >${D}/${KERNEL_IMAGEDEST}/extlinux/extlinux.conf << EOF
DEFAULT primary
TIMEOUT 10
MENU TITLE Boot Options
LABEL primary
      MENU LABEL primary ${KERNEL_IMAGETYPE}
      LINUX /${KERNEL_IMAGETYPE}
      APPEND \${cbootargs} ${KERNEL_ARGS} ${kernelRootspec} \${os_cmdline}
EOF
    kernelRootspec="${KERNEL_ROOTSPEC_FLASHER}" ; cat >${D}/${KERNEL_IMAGEDEST}/extlinux/extlinux.conf_flasher << EOF
DEFAULT primary
TIMEOUT 10
MENU TITLE Boot Options
LABEL primary
      MENU LABEL primary ${KERNEL_IMAGETYPE}
      LINUX /${KERNEL_IMAGETYPE}
      APPEND ${KERNEL_ARGS} ${kernelRootspec} \${os_cmdline}
EOF
}


do_install[postfuncs] += "generate_extlinux_conf"
do_install[depends] += "${@['', '${INITRAMFS_IMAGE}:do_image_complete'][(d.getVar('INITRAMFS_IMAGE', True) or '') != '' and (d.getVar('TEGRA_INITRAMFS_INITRD', True) or '') == "1"]}"

do_deploy_append(){
    mkdir -p "${DEPLOYDIR}/boot/"
    install -m 0600 "${D}/boot/extlinux/extlinux.conf" "${DEPLOYDIR}/boot/"
    install -m 0600 "${D}/boot/extlinux/extlinux.conf_flasher" "${DEPLOYDIR}/boot/"
}

FILES_${KERNEL_PACKAGE_NAME}-image_append = "/boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf_flasher"
