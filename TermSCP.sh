#!/bin/bash
function slowtype() {
local text=$(tr -d '\0' < $1)
for ((i=0;i<${#text};i++));
  do
      sleep 0.0$(((RANDOM%$Speed)+0))
      echo -n "${text:i:1}";
done
}
function trap_ctrlc ()
{
	echo -e 'Speed='$Speed'\nOffline='$Offline > $FILE/settings
	echo -e '\n\nDisconnected from database\n'
	if [ $Offline == False ]; then
		rm  "$FILE/tmp/$SCPNo)" "$FILE/tmp/$SCPNo"
	fi
	stty echo
	exit 2
}
trap "trap_ctrlc" 2
FILE="$HOME/.scp"
if [ ! -d $FILE ]; then
	mkdir "$FILE" "$FILE/offline" "$FILE/tmp";
fi
if ! [ -f "$FILE/settings" ]; then
	touch  "$FILE/settings"
	echo -e 'Speed=5\nOffline=True' > $FILE/settings
fi 
if [ ! -d "$FILE/offline" ]; then
		mkdir "$FILE/offline";
fi
source $FILE/settings
Offline=${Offline}
Speed=${Speed}
if [[ $1 == -h ]] || [[ $1 == --help ]]; then
	echo "Use:"
	echo "$0 [SCP Entry Number]"
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
		echo "		 $0 $1 offline		Changes whether scp are storred on drive or not"
		echo ""
		exit
	elif [ $2 == "offline" ]; then
		read -p "Do you want to store SCP entries offline? [true or false] " write
		case $write in
		"true" | "T" | "t" | "True" | "yes" | "y" | "Yes")
		echo "Offline set to true. Now when you open SCP entries they will be saved to your drive."
		Offline=True
		echo -e 'Speed='$Speed'\nOffline='$Offline > $FILE/settings
		;;
		"false" | "f" | "F" | "False"| "no" | "n" | "No")
		echo "Offline set to false. SCP entries will no longer be saved to your hard drive."
		Offline=False
		echo -e 'Speed='$Speed'\nOffline='$Offline > $FILE/settings
		if [ "yes" == "yes" ]; then
			echo ""
			read -p 'Would you like to DELETE previously storred entries? [yes or no] ' storage
			case $storage in
			"true" | "T" | "t" | "True" | "yes" | "y" | "Yes")
			rm $FILE/offline/*
			echo -e 'Local SCP entries have been deleted/n'
			
			;;
			"false" | "f" | "F" | "False"| "no" | "n" | "No")
			echo -e '\n'
			;;
			*)
				echo -e '\nInvalid input\n'
				;;
				esac
			fi
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
		export Speed=$write
		echo -e 'Speed='$Speed'\nOffline='$Offline > $FILE/settings
		exit
	fi
fi
echo -e "Welcome back $USER, to the SCP database"

if ! [ -z $1 ]; then
	SCPNo=$1
else
	read -p "What SCP would you like?: " SCPNo
fi
if [ -f "$FILE/offline/$SCPNo" ]; then
		echo "   Item #: SCP-$SCPNo"
		slowtype $FILE/offline/$SCPNo $Speed
fi
if [ $Offline == True ]; then
		echo "   Item #: SCP-$SCPNo"
	 	lynx -dump -nolist http://www.scpwiki.com/scp-$SCPNo > $FILE/tmp/$SCPNo
		cat  $FILE/tmp/$SCPNo | grep -izoP '(?<=Item #: SCP-'$SCPNo')(?s).*(?=« SCP-)'  > $FILE/offline/$SCPNo
		if [ -S $FILE/offline/$SCPNo ]; then
			stty -echo
			slowtype $FILE/offline/$SCPNo $Speed
		else
			rm $FILE/offline/$SCPNo
			cat  $FILE/tmp/$SCPNo | grep -izoP '(?<=SCP-'$SCPNo')(?s).*(?=« SCP-)'  > $FILE/offline/$SCPNo
			if ! [ -S $FILE/offline/$SCPNo ]; then
				rm $FILE/offline/$SCPNo
				cat  $FILE/tmp/$SCPNo | grep -izoP '(?<=SCP-'$SCPNo')(?s).*(?=page revision)'  > $FILE/offline/$SCPNo
					if  [ -S $FILE/offline/$SCPNo ]; then
						slowtype $FILE/offline/$SCPNo
						
						else
							echo "Problem connecting to database, please try again later."
							rm $FILE/tmp/$SCPNo $FILE/offline/$SCPNo
						fi
			else
				slowtype $FILE/offline/$SCPNo $Speed
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
 	slowtype $FILE/offline/$SCPNo $Speed
	stty echo
fi
