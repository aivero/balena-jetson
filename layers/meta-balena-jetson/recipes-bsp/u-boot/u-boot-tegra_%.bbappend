FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

UBOOT_KCONFIG_SUPPORT = "1"

inherit resin-u-boot

RESIN_BOOT_PART_jetson-nano = "0xC"
RESIN_DEFAULT_ROOT_PART-jetson-nano = "0xD"

RESIN_BOOT_PART_jetson-tx2 = "0x18"
RESIN_DEFAULT_ROOT_PART_jetson-tx2 = "0x19"

SRC_URI_append_jetson-nano = " \
    file://0001-Integrate-with-Balena-u-boot-environment.patch \
"

SRC_URI_append_jetson-tx2 = " \
    file://tx2-Integrate-with-Balena-u-boot-environment.patch \
"

generate_resinos_uenv_flasher() {
cat >${DEPLOY_DIR_IMAGE}/boot/resinOS_uEnv.flasher.txt << EOF
l4t_version=321
EOF
}

do_install[postfuncs] += "generate_resinos_uenv_flasher"
