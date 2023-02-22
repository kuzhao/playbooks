#!/bin/bash

## CONST
WORK='/mnt/img'
DD_SIZE=3500
DD_BS=1M
IMG='disk.img'
RASP_IMG_FILE='2022-09-22-raspios-bullseye-arm64-lite.img.xz'
RASP_IMG_DNLD="https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/${RASP_IMG_FILE}"
## Dependencies
sudo apt-get install -y parted

## FUNCTION
dd_empty_img_losetup_format() {
        dd if=/dev/zero bs=$DD_BS seek=$DD_SIZE count=0 of=$WORK/$IMG
        parted $IMG mklabel msdos
        parted $IMG mkpart primary fat32 4MiB 260MiB
        parted $IMG mkpart primary ext4 260MiB 3.2GiB
        mkdir fs-new boot-new
        losetup --find --partscan $IMG
        local LOOPDEV=$(losetup -a | grep $IMG | cut -d ':' -f1)
        mkfs.fat -F 32 ${LOOPDEV}p1
        mkfs.ext4 ${LOOPDEV}p2
        mount ${LOOPDEV}p1 boot-new
        mount ${LOOPDEV}p2 fs-new
        PARTUUID=$(blkid | grep ${LOOPDEV}p2 | grep 'PARTUUID=.*$' -o | grep '".*"' -o | tr -d '"')
}

download_losetup() {
        wget $RASP_IMG_DNLD
        xz -d ${RASP_IMG_DNLD##*/}
        local RPI_IMG=$(ls | grep \.img$)
        mkdir fs boot
        losetup --find --partscan $RPI_IMG
        local LOOPDEV=$(losetup -a | grep $RPI_IMG | cut -d ':' -f1)
        mount ${LOOPDEV}p1 boot
        mount ${LOOPDEV}p2 fs
        # mkdir overlay
        # mkdir upper work
        # mount -t overlay overlay -o lowerdir=fs,upperdir=upper,workdir=work overlay/
}

replace_partuuid() {
        sed -E -i "s/PARTUUID=\S+/PARTUUID=$PARTUUID/" boot-new/cmdline.txt
}

## MAIN
mkdir -p $WORK && cd $WORK;sudo chown $USER $WORK
download_losetup
dd_empty_img_losetup_format
rsync -a boot/* boot-new
rsync -a fs/* fs-new
replace_partuuid
