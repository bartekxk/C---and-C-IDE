#!/bin/bash
# Author           : Bartłomiej Kocot ( bartekkocot@op.pl )
# Created On       : 26.04.2018
# Last Modified By : Bartłomiej Kocot ( bartekkocot@op.pl )
# Last Modified On : data 
# Version          : 1.00
#
# Description      : 
# Opis		   :
# The script will be an environment for writing programs in C and C ++. He will let it
# set the compilationf option, execute it and help the programmer to write the code
# program.
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)
key="$1"
setkey=""
d="false"
unvar="false"
#help
if [[ $key = "-h" ]]; then
echo -e "The script will be an environment for writing programs in C and C ++. He will let it set the compilation option, execute it and help the programmer to write the code program. \n
-v - version of scrypt \n
-h - help \n
-s - fast compilation and run"
exit
fi 
#version
if [[ $key = "-v" ]]; then
echo -e "Author: Bartłomiej Kocot \n Version 1.00"
exit
fi 
#fast compilation
if [[ $key = "-s" ]]; then
file="$2"
filename="${file%.*}"
make $filename
./${filename} 
exit
fi 
menu=("New Project" "Open Project" "Settings" "Exit")
nfile=""
ofile=""
ntext=""
otext=""
created=0
if [[ $(dpkg-query -W -f='${Status}' g++ 2>/dev/null | grep -c "ok installed") -eq 0 ||  $(dpkg-query -W -f='${Status}' gcc 2>/dev/null | grep -c "ok installed") -eq 0 ]];
then
 zenity --error  --text="There are no appropriate packages to compile. For the program to work properly, an installation is required! Install and restart the program." 2>/dev/null
 sudo apt-get install  build-essential manpages-dev;
 exit
 # installing gcc and g++ from properly work
fi
#new project
newp()
{
created=1
nfile=$(zenity --entry --text "Enter the file name (extension .c or .cpp)" --entry-text ".cpp" 2>/dev/null);
if [ $? -eq 1 ]; then
return
fi
nfilename="${nfile%.*}"
if [[ ! -f $nfile && $? -eq 0 && ${#nfile} -gt 0 && ( ${nfile:(-4)} = ".cpp" || ${nfile:(-2)} = ".c" ) ]]; then
# we check if the file name is empty, not exist and if it has a good extension
ntext=`zenity --text-info --title $nfile --cancel-label "Return without saving" --ok-label "Compile and Run" --editable --width 1200 --height 800 > $nfile 2>/dev/null`
if [ $? -eq 0 ]; then
chmod 777 $nfile
make $setkey$nfilename
./${nfilename} 
zenity --info --title $nfile --text "The program was started in the terminal, clik ok to continue coding" 2>/dev/null
ofile=$nfile
otext=$ntext
openp
fi
else
zenity --warning --text "Incorrect file name or bad extension." 2>/dev/null
created=0
newp
fi
}
#open exist project
openp()
{
if [[ created -eq 0 ]]; then
ofile=`zenity --file-selection 2>/dev/null`
if [ $? -eq 1 ]; then
return
fi
else
ofile=$nfile
fi
cp -R $ofile "temp"
ofilename=${ofile##*/}
ofilename="${ofilename%.*}"
if [[ ${ofile:(-4)} = ".cpp" || ${ofile:(-2)} = ".c" ]]; then
# we check if the file name is empty, not exist and if it has a good extension
temp=$(cat "$ofile")
otext=$(echo -n "$temp" | zenity --text-info --title $ofile --editable --cancel-label "Return without saving" --ok-label "Compile and Run" --width 1200 --height 800 >$ofile 2>/dev/null)
if [ $? -eq 0 ]; then
chmod 777 $ofile
make  $setkey$ofilename
./${ofilename} 
zenity --info --title $ofile --text "The program was started in the terminal, clik ok to continue coding" 2>/dev/null
created=1
openp
else
cp -R "temp" $ofile
fi
else
zenity --warning --text "Required extension .c or .cpp." 2>/dev/null
openp
fi
}
settings()
{
options=("Debug: $d" "Warn Undefined Variables: $unvar")
sselected=`zenity --list --column=Menu "${options[@]}" --title "Settings" --cancel-label "Back" --height 500 --width 500 2>/dev/null`
if [ $? -eq 1 ]; then
return
fi
sselected="$(echo $sselected | head -c 1)"
case $sselected in
"D") 
if [[ $d = "false" ]]; then
d="true"
else
d="false"
fi;;
"W") 
if [[ $unvar = "false" ]]; then
unvar="true"
else
unvar="false"
fi;;
esac
if [[ $d = "true" ]]; then
setkey=" -d"
fi
if [[ $unvar = "true" ]]; then
setkey=$setkey" --warn-undefined-variables"
setkey=$setkey" "
settings
fi
}
for ((;;))
do
#create menu
optionselected=`zenity --list --column=Menu "${menu[@]}" --title "Menu" --cancel-label "Exit" --height 500 --width 500 2>/dev/null`
if [ $? -eq 1 ]; then
exit
fi
created=0
case $optionselected in
"New Project") newp;;
"Open Project") openp;;
"Settings") settings;;
"Exit") exit;;
esac
done
