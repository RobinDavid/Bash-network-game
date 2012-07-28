#!/bin/bash
#./keyboard ipserver portserver
test $# -ne 2 && echo -e "USAGE:\n$0 [SERVER_IP] [SERVER_PORT]" && exit 1
HOST=$1
PORT=$2


while :
do
	exec 5<>/dev/tcp/$HOST/$PORT 	#open a socket on the file descriptor 5
	test $? -eq 0 && break		#try to connect until it succeed
	echo "Try again in 5s..."
	sleep 5
done
clear
echo "Connection established"

while :
do
	read -sn1 a
	if [ "$a" == `echo -en "\e"` ]; then	#keycodes of arrows are \e[A \e[B \e[C \e[D
		read -sn1 a
		if [ "$a" == "[" ]; then
			read -sn1 a
			case "$a" in
				A)  touche="1";;	#UP
				B)  touche="2";;	#DOWN
				C)  touche="3";;	#RIGHT
				D)  touche="4";;	#LEFT
			esac
		fi
	else
		touche=$a	#if it's not an arrow we put directly the value of the key
	fi
        
	echo "$touche" >&5	#write the key to the file descriptor, which will send it to the server
done 

exit 0
