

#!/bin/bash

# Assignment 2
# Course:                OPS435
# Family Name(s):        Yadram Mohan, Edmund Adderley, Dilord Diza
# Student Number(s):     034-960-146, 048-459-143, 049-960-149 
# Login name(s):         ymohan, eadderley, dtdiza
# Professor:             Les Czegel
# Due Date:              August 7, 2015
#
# We declare that the attached assignment is our own work in accordance with
# Seneca Academic Policy.  No part of this assignment has been copied manually
# or electronically from any other source (including web sites) or distributed
# to other students.

menu() {
echo "  Owner   Group   Other   Filename" | cut -c-$(tput cols)
echo "  -----   -----   -----   --------" | cut -c-$(tput cols)
echo -n $'\n'

for dir_name in ${dir_array[@]}
do
    file_path="$file_path$dir_name"
    permission=$(ls -ld $file_path)
    echo -n "$(echo ${permission:0:1}) $(echo ${permission:1:1}) $(echo ${permission:2:1}) $(echo ${permission:3:1})   $(echo ${permission:4:1}) $(echo ${permission:5:1}) $(echo ${permission:6:1})   $(echo ${permission:7:1}) $(echo ${permission:8:1}) $(echo ${permission:9:1})   $dir_name"  | cut -c-$(tput cols)
	echo -n  $'\n'
    if [ "$counter" -ge "1" ]; then
       file_path="$file_path/"
    fi
       counter=$((counter+1))
       line_counter=$((line_counter+2))
done
file_path=""

tput cup $(($(tput lines)-4)) 0
    echo "Valid keys: k (up), j (down): move between filenames" | cut -c-$(tput cols)
    echo "            h (left), l (right): move between permissions" | cut -c-$(tput cols)
    echo "            r, w, x, -: change permissions;   q: quit" | cut -c-$(tput cols)
}

trap 'stty icanon icrnl echo; tput cup $(tput lines) 0; exit 0' INT

if [ "$#" = "0" ]; then
    set .
	elif [ "$#" != "1" ]; then
      echo "Useage: vchmod [ filename ]" >&2
        exit 1
fi
if [ ! -f "$1" ] && [ ! -d "$1" ]
   then
      echo "'$1' does not exit or is inaccessible" >&2
        exit 1
fi
if [ ! -x "$1" ]
   then
      echo "'$1' does not have execute permission" >&2
        exit 1
fi

clear

directory=$(readlink -e $1)
dir_array=(\/ ${directory//\// })
counter=0
cur_col=26
loop=0
stty -icanon -icrnl min 1 time 0 -echo

tput cup 0 0

line_counter=1

menu

while true
do

if [ "$loop" -lt "1" ]; then
	cur_row="$line_counter"
fi

second_path=""
for ((i=0;i<$(((cur_row-1)/2));i++))
do
   if [ "$i" -ge "1" ]; then
   second_path="$second_path/${dir_array[$i]}"
  else second_path="$second_path${dir_array[$i]}"
fi
done

if [ "$loop" -ge "1" ]; then
   tput cup $((cur_row+1)) 2
      ls -ld $second_path | awk '{print "Links:", $2, "Owner:", $3, "Group:", $4, "Size:", $5, "Modified:", $6, $7, $8}' | cut -c-$(($(tput cols)-2))
else tput cup $((line_counter+1)) 2
        ls -ld $second_path | awk '{print "Links:", $2, "Owner:", $3, "Group:", $4, "Size:", $5, "Modified:", $6, $7, $8}' | cut -c-$(($(tput cols)-2))
fi

if [ "$loop" -ge "1" ]; then
   tput cup $cur_row $cur_col
   else tput cup $line_counter $cur_col
      cur_row=$line_counter
fi

cmd=$(dd bs=3 count=1 2> /dev/null)
case $cmd in
    h) if [ "$cur_col" -gt "2" ]; then
          if [ "$cur_col" -eq "26" ] || [ "$cur_col" -eq "18" ] || [ "$cur_col" -eq "10" ]; then
             cur_col=$((cur_col - 4))
            else cur_col=$((cur_col - 2))
          fi
         elif [ "$cur_col" -eq "2" ]; then
            cur_col=2
       fi ;;
    l) if [ "$cur_col" -le "24" ]; then
          if [ "$cur_col" -eq "6" ] || [ "$cur_col" -eq "14" ] || [ "$cur_col" -eq "22" ]; then
             cur_col=$((cur_col + 4))
            else cur_col=$((cur_col + 2))
          fi
         elif [ "$cur_col" -eq "24" ]; then
              cur_col=26
       fi ;;
    j) tput cup $((cur_row+1)) 2
	   tput el
	   if [ "$cur_row" -lt "$((line_counter-1))" ]; then
          cur_row=$((cur_row + 2))
         elif [ "$cur_row" -eq "$((line_counter-1))" ]; then
              cur_row=$((line_counter-1))
       fi ;;
    k) tput cup $((cur_row+1)) 2
	   tput el
	   if [ "$cur_row" -gt "3" ]; then
          cur_row=$((cur_row - 2))
         elif [ "$cur_row" -eq "3" ]; then
              cur_row=3
       fi ;;
    q) tput cup $(tput lines) 0
       stty icanon icrnl echo
       exit 0 ;;
    r) if [ "$cur_col" = "2" ]; then
          chmod u+r $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "r" 
          fi
       fi
       if [ "$cur_col" = "10" ]; then
          chmod g+r $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "r" 
          fi
       fi
       if [ "$cur_col" = "18" ]; then
          chmod o+r $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "r" 
          fi
       fi ;;
    w) if [ "$cur_col" = "4" ]; then
          chmod u+w $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "w" 
          fi
       fi
       if [ "$cur_col" = "12" ]; then
          chmod g+w $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "w" 
          fi
       fi
       if [ "$cur_col" = "20" ]; then
          chmod o+w $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "w" 
          fi
       fi ;;
    x) if [ "$cur_col" = "6" ]; then
          chmod u+x $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "x" 
          fi
       fi
       if [ "$cur_col" = "14" ]; then
          chmod g+x $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "x" 
          fi
       fi
       if [ "$cur_col" = "22" ]; then
          chmod o+x $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "x" 
          fi
       fi ;;
    -) if [ "$cur_col" = "2" ]; then
          chmod u-r $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi
       if [ "$cur_col" = "10" ]; then
          chmod g-r $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi
       if [ "$cur_col" = "18" ]; then
          chmod o-r $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi
       if [ "$cur_col" = "4" ]; then
          chmod u-w $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi
       if [ "$cur_col" = "12" ]; then
          chmod g-w $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi
       if [ "$cur_col" = "20" ]; then
          chmod o-w $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi
       if [ "$cur_col" = "6" ]; then
          chmod u-x $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi
       if [ "$cur_col" = "14" ]; then
          chmod g-x $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi
       if [ "$cur_col" = "22" ]; then
          chmod o-x $second_path 2> /dev/null
	      if [ $? = 0  ] ; then
             echo $'\b' "-" 
          fi
       fi ;;
esac
loop=$((loop+1))
done

