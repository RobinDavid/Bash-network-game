#!/bin/bash
#./display local_port
test $# -ne 1 && echo -e "USAGE:\n$0 [PORT]" && exit 1
test `which netcat &>/dev/null; echo $?` -ne 0 && echo "please install netcat before running display.sh" && exit 1
test `which dialog &>/dev/null; echo $?` -ne 0 && echo "please install dialog before running display.sh" && exit 1
#exit if the programs are not installed

#-- declarations --
PORT=$1
fifo=/tmp/$PORT
test -e $fifo || mkfifo $fifo
HEIGHT=9 #10 #8 in reallity(the behavior of dialog is really weird)
WIDTH=29 #30 #25 in reallity(the behavior of dialog is really weird)
REALHEIGHT=7
REALWIDTH=25
posx=0
posy=0
#------------------

netcat -l -p $PORT >$fifo &	#listen on the specified port, and write words read to the fifo
pidnetcat=$!			#useless
#trap "kill -15 $pidnetcat && exit 0" SIGINT SIGTERM


affiche_curse ()
{
	dialog --no-shadow --title "$message" --infobox "`echo ${c[*]} | xargs -n $REALWIDTH|sed -e 's/ //g' -e 's/O/\`/g' -e 's/w\|s/\|/g' -e 's/a\|d/-/g' -e 's/[0-9]//g'`" $HEIGHT $WIDTH
	#the command above is the main command of the script
	#it parse the table, replacing the "chars code" to their representation
}

while :
do
	read -sn1 state			#first thing send is the game status
        read c				#after read the table to print
	
	test "$c" != "" || continue	#if nothing is received, we continue
	case "$state" in
		"0") message="In Progress";;
		"1") dialog --msgbox "`echo -e "Congratulation\nYou won !"`" $HEIGHT $WIDTH;break;;
		"2") dialog --msgbox "`echo -e "\nYou failed !"`" $HEIGHT $WIDTH;break;;
		"2") message="You loose";;
	esac
	affiche_curse
	# above call the print function

	sleep 0.01

done <$fifo	#read from to fifo wich is written by the netcat process

if kill -15 $pidnetcat
then
       echo "fin"
else
        echo "netcat stop, fail"
fi

exit 0
