include resin-image.inc

RESIN_BOOT_PARTITION_FILES_append_jetson-tx2 = " \
    boot/extlinux.conf_flasher:/extlinux/extlinux.conf \
    boot/resinOS_uEnv.flasher.txt:/resinOS_uEnv.txt \
"
INTERNAL_DEVICE_KERNEL_jetson-tx2 = "mmcblk0"
