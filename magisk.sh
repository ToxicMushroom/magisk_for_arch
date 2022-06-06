#Dependencies
echo "##############################################################################################"
echo "Installing dependencies"
echo "##############################################################################################"
sudo apt install adb fastboot dos2unix unzip ed curl -y
PATH=$PATH:/usr/lib/android-sdk/platform-tools/fastboot
PATH=$PATH:/usr/lib/android-sdk/platform-tools/adb
#Delete old dir
echo "Deleteting old dir"
rm -rf /home/$USER/Magisk
#Make a dir for download
mkdir /home/$USER/Magisk
cd /home/$USER/Magisk
#Download lastest release
echo "##############################################################################################"
echo "Downloading lastest magisk"
echo "##############################################################################################"
wget $(curl -s https://api.github.com/repos/topjohnwu/Magisk/releases/latest | grep 'browser_download_url' | cut -d\" -f4)
#Remove no needed apk
rm /home/$USER/Magisk/stub-release.apk
#Unzip the apk on his directory
echo "##############################################################################################"
echo "Unzipping"
echo "##############################################################################################"
mkdir /home/$USER/Magisk/wokdir
unzip /home/$USER/Magisk/Magisk* -d /home/$USER/Magisk/wokdir
#Create direcorty where file will be copied
mkdir /home/$USER/Magisk/pc_magisk
#Copy all files needed
echo "##############################################################################################"
echo "Copying files"
cp /home/$USER/Magisk/wokdir/assets/boot_patch.sh /home/$USER/Magisk/pc_magisk/boot_patch.sh
cp /home/$USER/Magisk/wokdir/assets/util_functions.sh /home/$USER/Magisk/pc_magisk/util_functions.sh
cp /home/$USER/Magisk/wokdir/lib/x86_64/libmagiskboot.so /home/$USER/Magisk/pc_magisk/magiskboot
cp /home/$USER/Magisk/wokdir/lib/armeabi-v7a/libmagisk32.so /home/$USER/Magisk/pc_magisk/magisk32
cp /home/$USER/Magisk/wokdir/lib/arm64-v8a/libmagisk64.so /home/$USER/Magisk/pc_magisk/magisk64
cp /home/$USER/Magisk/wokdir/lib/arm64-v8a/libmagiskinit.so /home/$USER/Magisk/pc_magisk/magiskinit
#Remove old dir
rm -rf /home/$USER/Magisk/wokdir
#Enter into folder 
cd /home/$USER/Magisk/pc_magisk
#Get line
echo "##############################################################################################"
echo "Adapting script for pc"
echo "##############################################################################################"
line=$(grep -n '/proc/self/fd/$OUTFD' util_functions.sh | awk '{print $1}' | sed 's/.$//')
#Edit the scripts
KEYWORD="/proc/self/fd/$OUTFD";
ESCAPED_KEYWORD=$(printf '%s\n' "$KEYWORD" | sed -e 's/[]\/$*.^[]/\\&/g');
sed -i "/$ESCAPED_KEYWORD/d" util_functions.sh
#Add echo "$1"
(echo "$line-1"; echo a; echo 'echo "$1"'; echo .; echo wq) | ed util_functions.sh 
#Replace getprop
sed -i 's/getprop/adb shell getprop/g' util_functions.sh 
#Adb
echo "##############################################################################################"
echo "Waiting for adb conenction"
echo "##############################################################################################"
echo "Waiting for adb conection"
while true; do adb get-state > /dev/null 2>&1 && break; done
#Patch
echo "##############################################################################################"
echo "Be sure adb is running and you have allowed on your phone"
echo "##############################################################################################"
echo "Now if the adb is working we can patch the image"
echo ""
read -e -p "Enter filename : " file
eval xyz=${abc[i]}
eval file=$file
echo "$file" | tr -d ''
sh boot_patch.sh $file
