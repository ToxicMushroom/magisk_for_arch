# magisk_for_linux

- !BEFORE RUN MAKE SURE YOU HAVE USB DEBUG ENABLED AND YOU HAVE TRUSTED THE COMPUTER!
- !THIS RUN ONLY ON DEBIAN BASED! APT COMMANDS!
- !YOU CAN REPLACE THEM WITH YOUR DISTRO PACKAGE MANAGER!

If you got stuck on "unpacking boot image", use the magisk_canary.sh instead.

If this not fix the issue and you are on ubuntu, try to install the last unzip from this repo using sudo dpkg -i unzip_amd64.deb.

# Tested on ubuntu (20.04, 22.04) and debian 9 64 bit.

1 - Allow the script to be executed typing on terminal -->> chmod +x magisk.sh

2 - Run the script  -->> ./magisk.sh

3 - When it will ask for a device connect it

4 - Insert the path to the stock boot.img

5 - Wait and when completed your file will be on /home/$USER/Magisk/pc_magisk

Since this script patch only the boot.img, there's a patched vbmeta image too in this repo. 

Command to generate the vbmeta image --> avbtool make_vbmeta_image --flags 2 --padding_size 4096 --output vbmeta_disabled.img

Based on the things discovered by https://dev.sect0uch.world/SecT0uch/Magisk_boot_flasher#run-patch-boot-locally.
