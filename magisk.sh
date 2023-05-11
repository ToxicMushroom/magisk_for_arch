#!/bin/bash
RUN_FROM_DIR=$(pwd)

# sudo check
if [ "$(whoami)" = root ]; then
    echo "This script should not be run as root."
    exit 1
fi

# the temp directory used
WORK_DIR=$(mktemp -d)

# check if tmp dir was created
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi

# deletes the temp directory
function cleanup {
  rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT


echo "Make sure the following packages are installed: (adb fastboot dos2unix unzip curl ed)"

function announce_section {
    local message=$1
    local length=${#message}
    local line=""

    # Build the line of hashtags
    for ((i = 0; i < length; i++)); do
        line+="#"
    done

    # Print the message surrounded by hashtags
    echo "$line"
    echo "$message"
    echo "$line"
}

# Menu
mainmenu() {
    echo "Which Magisk version ?
    1) Use Magisk releases
    2) Use Magisk canary"
    read -r -p "Choose an option (default=1): " ans

    case $ans in
    1)
        announce_section "Downloading Magisk release"
        local magisk_apk_url;
        magisk_apk_urls="$(curl -s https://api.github.com/repos/topjohnwu/Magisk/releases/latest | grep 'browser_download_url' | cut -d\" -f4)"
        for magisk_apk_url in $magisk_apk_urls
        do
            wget -P "$WORK_DIR" "$magisk_apk_url"
        done
        ;;
    2)
        announce_section "Downloading Magisk canary"
        wget https://raw.githubusercontent.com/topjohnwu/magisk-files/canary/app-debug.apk
        ;;
    *)
        echo "There is nothing left to do."
        exit 1
        ;;
    esac
}

mainmenu

# Unzip the apk
announce_section "Extracting apk"
mkdir "$WORK_DIR"/wokdir
unzip "$WORK_DIR"/Magisk* -d "$WORK_DIR"/wokdir

# Create directory where files will be copied
mkdir "$WORK_DIR"/pc_magisk

# Move all required files
announce_section "Moving files"
mv -v "$WORK_DIR"/stub-release.apk "$WORK_DIR"/pc_magisk/stub.apk
mv -v "$WORK_DIR"/wokdir/assets/boot_patch.sh "$WORK_DIR"/pc_magisk/boot_patch.sh
mv -v "$WORK_DIR"/wokdir/assets/util_functions.sh "$WORK_DIR"/pc_magisk/util_functions.sh
mv -v "$WORK_DIR"/wokdir/lib/x86_64/libmagiskboot.so "$WORK_DIR"/pc_magisk/magiskboot
mv -v "$WORK_DIR"/wokdir/lib/armeabi-v7a/libmagisk32.so "$WORK_DIR"/pc_magisk/magisk32
mv -v "$WORK_DIR"/wokdir/lib/arm64-v8a/libmagisk64.so "$WORK_DIR"/pc_magisk/magisk64
mv -v "$WORK_DIR"/wokdir/lib/arm64-v8a/libmagiskinit.so "$WORK_DIR"/pc_magisk/magiskinit

# Remove extraction output
rm -rf "$WORK_DIR"/wokdir

# Enter into build folder
cd "$WORK_DIR"/pc_magisk || exit 2

# Get line
announce_section "Adapting script for pc"

# shellcheck disable=SC2016
line=$(grep -n '/proc/self/fd/$OUTFD' util_functions.sh | awk '{print $1}' | sed 's/.$//')
echo "Editing /proc/self/fd/\$OUTFD ref on line: $line in util_functions.sh"
# Edit the scripts
KEYWORD="/proc/self/fd/$OUTFD"
ESCAPED_KEYWORD=$(printf '%s\n' "$KEYWORD" | sed -e 's/[]\/$*.^[]/\\&/g')
sed -i "/$ESCAPED_KEYWORD/d" util_functions.sh
# Add echo "$1"
(
    echo "$line-1"
    echo a
    # shellcheck disable=SC2016
    echo '    echo "$1"'
    echo .
    echo wq
) | ed util_functions.sh

echo "Replacing all getprop references"
sed -i 's/getprop/adb shell getprop/g' util_functions.sh

#Adb

announce_section "Waiting for adb connection"
while true; do
    adb get-state >/dev/null 2>&1 && break;
    sleep 1
done
# Patch
announce_section "You need to accept the popup that appears on the phone"
echo "Now if adb is working we can patch the image"
echo ""
read -r -e -p "Drag & drop your boot.img : " file
eval "file=$file"
ls
/bin/bash -c 'PATCHVBMETAFLAG=true /bin/bash boot_patch.sh "$1"' _ "$file"
ls

mv -i new-boot.img "$RUN_FROM_DIR"