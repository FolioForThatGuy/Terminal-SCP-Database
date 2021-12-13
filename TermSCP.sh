#!/bin/bash
function slowtype() {
local text=$(tr -d '\0' < $1)
local speed=$2
for ((i=0;i<${#text};i++));
  do
      sleep 0.0$(((RANDOM%$speed)+0))
      echo -n "${text:i:1}";
done
}
function trap_ctrlc ()
{
	echo ""
	echo ""
	echo "Disconnected from database"
	echo ""
	if [ $offline == True ]; then
		rm  "$FILE/tmp/$SCPNo)" "$FILE/tmp/$SCPNo"
	fi
	stty echo
	exit 2
}
trap "trap_ctrlc" 2
FILE="$HOME/.scp"
if [ ! -d $FILE ]; then
	mkdir "$FILE" "$FILE/offline" "$FILE/offline" "$FILE/tmp";
fi
if [ ! -d "$FILE/offline" ]; then
		mkdir "$FILE/offline";
fi
if ! [ -f "$FILE/settings" ]; then
	touch $FILE/settings
	jq -n '{"speed":50, "offline": true}' > $FILE/settings
fi
speed=$(jq '.speed' $FILE/settings)
offline=$(jq '.offline' $FILE/settings)
if [[ $1 == -h ]] || [[ $1 == --help ]]; then
	echo "Use:"
	echo "$0 [scp Number]"
	echo "$0 --settings"
	echo "$0 -s"
	echo "$0 -s speed"
	echo "$0 -s offline [true/false]"
exit
fi
if [[ $1 == -s ]] || [[ $1 == --settings ]]; then
	if  [ -z $2 ]; then
		echo ""
		echo "		 $0 $1 speed 		Sets the speed text is written to the screen (lower is faster)"
		echo "		 $0 $1 offline		Changes storage settings"
		echo ""
		exit
	elif [ $2 == "offline" ]; then
		read -p "Do you want to store SCP documents offline? [true or false] " write
		case $write in
		"true" | "T" | "t" | "True")
		echo "Offline set to true. Now when you open scp documents they will be saved to your hard drive."
		cat <<< $(jq ".offline = true" $FILE/settings) >  $FILE/settings
		;;
		"false" | "f" | "F" | "False")
		echo "Offline set to false. Scp documents will no longer be saved to your hard drive. Previous instances of documents will be kept however."
		cat <<< $(jq ".offline = false" $FILE/settings) >  $FILE/settings
		;;
		*)
		  echo
			echo "Invalid input"
			echo
			;;
			esac
		exit
	elif [ $2 == "speed" ]; then
		read -p "What speed do you want text to be printed?: " write
		cat <<< $(jq ".speed = $write" $FILE/settings) >  $FILE/settings
		exit
	fi
fi
echo -e "Welcome back $USER, to the SCP database"

if ! [ -z $1 ]; then
	SCPNo=$1
else
	read -p "What SCP would you like?: " SCPNo
fi
if [ $offline == true ]; then
	if [ -f "$FILE/offline/$SCPNo" ]; then
		echo "   Item #: SCP-$SCPNo"
		slowtype $FILE/offline/$SCPNo $speed
	else
		echo "   Item #: SCP-$SCPNo"
	  lynx -dump -nolist http://www.scpwiki.com/scp-$SCPNo > $FILE/tmp/$SCPNo
		cat  $FILE/tmp/$SCPNo | grep -izoP '(?<=Item #: SCP-'$SCPNo')(?s).*(?=« SCP-)'  > $FILE/offline/$SCPNo
		if [ -s $FILE/offline/$SCPNo ]; then
			stty -echo
			slowtype $FILE/offline/$SCPNo $speed
		else
			rm $FILE/offline/$SCPNo
			cat  $FILE/tmp/$SCPNo | grep -izoP '(?<=SCP-'$SCPNo')(?s).*(?=« SCP-)'  > $FILE/offline/$SCPNo
			if ! [ -s $FILE/offline/$SCPNo ]; then
				rm $FILE/offline/$SCPNo
				cat  $FILE/tmp/$SCPNo | grep -izoP '(?<=SCP-'$SCPNo')(?s).*(?=page revision)'  > $FILE/offline/$SCPNo
					if  [ -s $FILE/offline/$SCPNo ]; then
						slowtype $FILE/offline/$SCPNo
						
						else
							echo "Problem connecting to database, please try again later."
							rm $FILE/tmp/$SCPNo $FILE/offline/$SCPNo
						fi
			else
				slowtype $FILE/offline/$SCPNo $speed
				rm $FILE/tmp/$SCPNo
					fi
		fi
		stty echo
		rm $FILE/tmp/$SCPNo
	fi
else
	echo "   Item #: SCP-$SCPNo"
	lynx -dump -nolist www.scpwiki.com/scp-$SCPNo > $FILE/tmp/$SCPNo
	cat  $FILE/tmp/$SCPNo | grep -izoP '(?<=Item #: SCP-'$SCPNo')(?s).*(?=« SCP-)' >"$FILE/tmp/$SCPNo)";
	rm  $FILE/tmp/$SCPNo
	stty -echo
 	slowtype $FILE/offline/$SCPNo $speed
	stty echo
fi
