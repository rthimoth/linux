#!/bin/bash
#03/01/2023
#testscript1

hostname="$(sudo hostnamectl | head -n 1 | cut -d':' -f2)"
os="$(cat /etc/redhat-release)"
kernel="$(uname -r)"
ip="$(ip a | grep inet | head -n 3 | tail -n 1 | tr -s ' ' | cut -d' ' -f3)"
memoryavailable="$( free -h -t | grep Total | cut -d ' ' -f24)"
totalmemory="$(free -h -t | grep Total | cut -d ' ' -f10)"
disk="$(df -H -t xfs | grep root | cut -d ' ' -f7)"


echo "machine name : ${hostname}
os name : ${os}
kernel name : ${kernel}
ip : ${ip}
ram : ${memoryavailable} memory available ${totalmemory} total memory
Disk : ${disk}  space left
top 5 processes by ram usage :"

while read super_line; do
  name="$(echo $super_line | cut -d ' ' -f1)"
  id="$(echo $super_line | cut -d ' ' -f2)"
  echo "  - ${name} ${id}"
done <<< "$(ps -eo %mem=,cmd= --sort=-%mem)" | head -n 5
echo "listening port:"
while read super_line; do
  name="$(echo $super_line | cut -d ':' -f1 | cut -d ' ' -f1)"
  id="$(echo $super_line | cut -d ':' -f2 | cut -d ' ' -f1)"
  prog="$(echo $super_line | cut -d '"' -f2)"
  echo "  - ${name} ${id} ${prog}"
done <<< "$(ss -ln4Hp)"
curl -s  https://cataas.com/cat -o cat
filetype=$(file cat)
if [[ $filetype == *GIF* ]] ; then
  file="gif"
elif [[ $filetype == *JPEG* ]] ; then
  file="jpeg"
elif [[ $filetype == *PNG* ]] ; then
  file="png"
else
  echo "This format is not supported."
  exit 1
fi
mv cat cat.${file}
echo " Random cat : ./cat.${file}"
