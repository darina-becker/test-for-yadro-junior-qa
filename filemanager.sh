#!/bin/bash

LOG_FILE="${HOME}/filemanager.log"

exec 3>>$LOG_FILE

log()
{
	date=`date +"%Y-%m-%d %T"`
	while IFS= read -r line
	do
		printf "[%s] %s\n" "$date" "$line" >&3
	done
}

show_help ()
{
	echo "
Choose one action from this list and enter its number:
1. Create directory
2. Change current directory
3. Print directory content
4. Create file
5. Delete file
6. Exit"
}

create_dir ()
{
	echo "Please enter the name of new directory"
	read name_new_dir
	if [[ -f $name_new_dir || -d $name_new_dir ]]
	then
		echo "File '$name_new_dir' already exists"
	else
		mkdir $name_new_dir 2> >(log)
		if [ $? -eq 0 ]
		then
			echo "Complete!"
		else
			echo "Oops, something went wrong. Check ${LOG_FILE}"
		fi
	fi
}

change_dir ()
{
	echo "Please enter the path to new directory"
	read path_new_dir
	if [ -f $path_new_dir ]
	then
		echo "'$path_new_dir' is not a directory"
	elif ! [[ -d $path_new_dir ]]
	then
		echo "'$path_new_dir' does not exist"
	else
		cd $path_new_dir 2> >(log)
		if [ $? -ne 0 ]
		then
			echo "Oops, something went wrong. Check ${LOG_FILE}"
		fi
	fi
}

show_content ()
{
	ls -la 2> >(log)
	if [ $? -ne 0 ]
	then
		echo "Oops, something went wrong. Check ${LOG_FILE}"
	fi
}

create_file ()
{
	echo "Please enter file's name"
	read file_name
	if [[ -d $file_name || -f $file_name ]]
	then
		echo "File or directory with the name already exists"
	else
		touch $file_name 2> >(log)
		if [ $? -eq 0 ]
		then
			echo "Complete!"
		else
			echo "Oops, something went wrong. Check ${LOG_FILE}"
		fi
	fi
}

delete_file ()
{
	echo "Please enter file's name you want to delete"
	read file_name_del
	if [[ -f $file_name_del ]]
	then
		echo "File $file_name_del will be deleted! Continue? (yes/no)"
		while true
		do
			read answer
			answer="$(echo $answer | tr '[:upper:]' '[:lower:]')"
			if [[ $answer == "yes" || $answer == "y" ]]
			then
				rm $file_name_del 2> >(log)
				if [ $? -eq 0 ]
				then
					echo "Complete!"
					break
				else
					echo "Oops, something went wrong. Check ${LOG_FILE}"
					break
				fi
			elif [[ $answer == "no" || $answer == "n" ]]
			then
				break
			else
				echo "File $file_name_del will be deleted! Continue? (yes/no)"
			fi

		done
	elif [[ -d $file_name_del ]]
	then
		echo "'$file_name_del' is a directory"
	else
		echo "'$file_name_del' does not exist"
	fi
}

if [[ -n $USER ]]
then 
	user_name=$USER
else
	user_name=$(whoami)
fi
echo "Hello, $user_name!"
show_help
re='^[0-9]+$'
while true
do
	printf "[%s]> " $PWD
	read numb_of_action
	if [[ -z $numb_of_action ]]
	then
		continue
	elif ! [[ $numb_of_action =~ $re ]]
	then
		echo "Please enter the number from 1 to 6!"
		show_help
	else
		case $numb_of_action in
		1)
			create_dir
			;;
		2)
			change_dir
			;;
		3)
			show_content
			;;
		4)
			create_file
			;;
		5)
			delete_file
			;;
		6)
			echo "Bye!"
			break
			;;
		*)
			echo "The number must be from 1 to 6! Please enter a correct value!"
			show_help
		esac
	fi
done
