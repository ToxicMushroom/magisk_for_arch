# magisk_for_linux

- BEFORE RUN MAKE SURE YOU HAVE USB DEBUG ENABLED AND YOU HAVE TRUSTED THE COMPUTER.
- THIS USE APT COMMANDS. YOU CAN REPLACE THEM WITH YOUR DISTRO PACKAGE MANAGER.
- Tested on ubuntu (20.04, 21.10, 22.04) and debian 11 64 bit.

# How to  run

     wget https://raw.githubusercontent.com/daboynb/magisk_for_linux/main/magisk.sh && chmod +x magisk.sh && sudo ./magisk.sh

  - When it will ask for a device connect it

  - Insert the path to the stock boot.img

  - Wait. When the process will be finished your patched boot.img will be on the /home/$USER/Magisk/pc_magisk foler

# Extras

Since this script patch only the boot.img, there's a patched vbmeta image too in this repo. 

Command to generate the vbmeta image by yourself --> avbtool make_vbmeta_image --flags 2 --padding_size 4096 --output vbmeta_disabled.img

# Credits 

Based on the things discovered by https://dev.sect0uch.world/SecT0uch/Magisk_boot_flasher#run-patch-boot-locally.
