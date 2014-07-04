#!/usr/bin/env bash
# Sonicwall config decoder and password extractor for John the Ripper
# Daniel Compton
# www.commonexploits.com
# contact@commexploits.com
# Twitter = @commonexploits
# 25/10/2013
# Tested on Bactrack 5 & Kali
# decodes Sonwicwall base4 encoded firewall password hashes from config files and reformats for John the Ripper cracking.

# Script begins
#===============================================================================

VERSION="1.0"
TMPSFILE="sonicwall-decoded-config.txt" #name of decoded sonci wall file used for script

clear
echo -e "\e[00;31m########################################################################################\e[00m"
echo -e "SoniJohn Version $VERSION "
echo ""
echo -e "SonicWall Firewall Config Decoder and Password Hash Converter For John The Ripper"
echo ""
echo "https://github.com/commonexploits/sonijohn"
echo -e "\e[00;31m########################################################################################\e[00m"
echo ""
echo -e "\e[1;31m------------------------------------------------------------------------------------------------------------------\e[00m"
echo -e "\e[01;31m[?]\e[00m Enter the location of the SonicWall Encoded config file i.e /tmp/sonicwall.exp (tab to complete path)"
echo -e "\e[1;31m------------------------------------------------------------------------------------------------------------------\e[00m"
echo ""
read -e SFILEIN
cat "$SFILEIN" >/dev/null 2>&1
 if [ $? = 1 ]
   then
     echo ""
     echo -e "\e[1;31m Sorry I can't read that file, check the path or format and try again!\e[00m"
     echo ""
     exit 1
fi

cat "$SFILEIN" |grep "&&" >/dev/null 2>&1
if [ $? = 1 ]
        then
                echo ""
                echo -e "\e[01;31m[!]\e[00m This does not seem to be a SonicWall config!"
                echo ""
                exit 1
        else
                echo ""
                echo -e "\e[01;32m[+]\e[00m This seems to be a Sonicwall encoded config file, I will now decode this"
                echo ""
fi

#Check for base64
which base64 >/dev/null
if [ $? -eq 1 ]
        then
                echo ""
                echo -e "\e[01;31m[!]\e[00m Unable to find the required base64 program. Install and try again!"
                exit 1
fi

#Base64 decode the config file
cat "$SFILEIN" |base64 -w0 -i -d |sed 's/&/\n&/g' > "$TMPSFILE"

#Extract hostname
HOSTNAME=$(cat "$TMPSFILE" |grep -i firewallname |cut -d "=" -f 2)
cat "$TMPSFILE" |grep -i firewallname |cut -d "=" -f 2 >/dev/null 2>&1
if [ $? = 1 ]
        then
                echo ""
                echo -e "\e[01;31m[!]\e[00m Something does not look correct, I was not able to properly Decode the config file!"
                echo ""
                exit 1
        else
                echo ""
                echo -e "\e[01;32m[+]\e[00m SonicWall config was successfully decoded for Firewall \e[01;32m"$HOSTNAME"\e[00m"
                echo ""
fi
rm sonic-john-hashes-"$HOSTNAME".txt >/dev/null 2>&1
#extract usernames
USERNAME=$(cat "$TMPSFILE" |grep userObjId |cut -d "=" -f 2)

for USERID in $(echo "$USERNAME")
do
SID=$(cat "$TMPSFILE" |grep "$USERID" |grep -i "userobjId_" |cut -d "_" -f 2 |cut -d "=" -f 1)
HASH=$(cat "$TMPSFILE" |grep "userObjCryptPass_"$SID"" |cut -d "=" -f 2 |cut -d "," -f 2)
echo "$USERID":"$HASH" >> sonic-john-hashes-"$HOSTNAME".txt
done
echo -e "\e[01;32m-----------------------------------------------------------------------\e[00m"
echo -e "\e[01;32m[+]\e[00m John format hashes for SonicWall Firewall \e[01;32m"$HOSTNAME"\e[00m"
echo -e "\e[01;32m-----------------------------------------------------------------------\e[00m"
echo ""
paste sonic-john-hashes-"$HOSTNAME".txt
echo ""
echo -e "\e[01;32m[-]\e[00m These have been saved to \e[01;32msonic-john-hashes-"$HOSTNAME".txt\e[00m"
echo ""
echo -e "\e[01;32m[-]\e[00m Just run john \e[01;32msonic-john-hashes-"$HOSTNAME".txt\e[00m"
echo ""
rm "$TMPSFILE" >/dev/null 2>&1
exit 0
