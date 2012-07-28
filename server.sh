#!/bin/bash 
#./server IPplayer IPplayer2

#----- gloal vars----
sym="M"			#symbol of the player
#--------------------

charge_table ()		#initialize the table (called, one time)
{
        for i in $(seq 0 `expr $REALWIDTH \* $REALHEIGHT`)
        do
                table[$i]="O"
        done
}

modifier_table ()	#replace an element in the table by another
{
	x=$1
	y=$2
	val=$3
	local temp=`expr \( $REALWIDTH \* $2 \) + $1`
	test ${3:0:1} = "$sym" && check_collision $temp "$sym${3:1:1}"
	table[$temp]=$val
}

check_collision ()	#check collision between players and missiles
{
	if [ ${2:0:1} != "$sym" ]; then		#if we check the collision of a missile
	case "${table[$1]:0:1}" in
		"w" | "a" | "s" | "d")	table[$1]="O";;
		"$sym") if [ ${table[$1]:1:1} -eq 1 ]; then
			state=2 #player 1 win
		     else
			state=1 #player 2 win
		     fi
			table[$1]="X";;
	esac
	else					#if we check the collision a player
	case "${table[$1]:0:1}" in
	"w" | "a" | "s" | "d") 			#player hurt missiles
		if [ ${2:1:1} -eq 1 ]; then
			state=2
		else
			state=1
		fi ;;
	"$sym") 				#player hurt the other player(win)
		if [ ${2:1:1} -eq 0 ]; then
			state=2
		else
			state=1
		fi;;
	esac
	fi
}

parser_table ()		#every the server receive new datas, it update the table (missiles position etc..)
{
# W is a missible which go up
# S is a missile which go down
# A is a missile which go left
# D is a missile which go right
#Note: the 0 or 1 after W/S/A/D means the missile had already move this round
#to avoid missiles which move higher in the table to be moved again
i=0
for e in ${table[@]}
do
	case "$e" in
	"w0")	if [ $i -gt $POSWIDTH ]; then		#if it do not leave the screen
			table[$i]="O"
			let "newpos = $i - $REALWIDTH"
			check_collision $newpos w
			table[$newpos]="w1"
		else 
			table[$i]="O"
		fi ;;
	"w1") table[$i]="w0" ;;
	"s0")	if [ $i -lt `expr $POSWIDTH \* $REALHEIGHT` ]; then
			table[$i]="O"
			let "newpos = $i + $REALWIDTH"
			check_collision $newpos s
			table[$newpos]="s1"
		else
			table[$i]="O"
		fi ;;
	"s1") table[$i]="s0" ;;
	"a0")	if [ 0 -ne `expr $i % $REALWIDTH` ]; then
			table[$i]="O"
			let "newpos = $i - 1"
			check_collision $newpos a
			table[$newpos]="a1"
		else
			table[$i]="O"
		fi ;;
	"a1") table[$i]="a0" ;;
	"d0")	if [ 0 -ne `expr \( $i + 1 \) % $REALWIDTH` ]; then 
			table[$i]="O"
			let "newpos = $i + 1"
			check_collision $newpos d
			table[$newpos]="d1"
		else
			table[$i]="O"
		fi ;;
	"d1") table[$i]="d0" ;; 
 	esac
	((i++))
done
}


if [ "$1" != "fork" ]
then
#Normally here forks never enter
test $# -ne 2 && echo -e "USAGE:\n$0 [IP_PLAYER1] [IP_PLAYER2]" && exit 1
test `which netcat &>/dev/null; echo $?` -ne 0 && echo "please install netcat before running server.sh" && exit 1

	#----Declarations/initializations----
	IPPLAYER1=$1
	IPPLAYER2=$2
	PORTPLAYER1=7001
	PORTPLAYER2=7002
	fifo="/tmp/`date +%s`"
	mkfifo $fifo
	HEIGHT=9 #10 #8 en realite
	WIDTH=29 #30 #25 en realite
	REALHEIGHT=7
	REALWIDTH=25
	POSWIDTH=`expr $REALWIDTH - 1`
	POSHEIGHT=`expr $REALHEIGHT - 1`
	posx[1]=0			#position of the first players(put them in a table is easier the manage)
	posy[1]=0			
	posx[2]=$POSWIDTH		#position of the second players
	posy[2]=$POSHEIGHT
	declare -a table
	charge_table
	modifier_table 0 0 "$sym"
	modifier_table $POSWIDTH $POSHEIGHT "$sym"
	#------------------------------------

	#below the launch of the two forks which will listen keys typed by user on the socket
	. $0 fork $fifo 1 &
	pidchild1=$!
	. $0 fork $fifo 2 &
	pidchild2=$!
	trap "kill -15 $pidchild1 && kill -15 $pidchild2 && exit 0" SIGINT SIGTERM
	echo -e "Mon pid: $$\npid fork1: $pidchild1\npid fork2: $pidchild2"

	#connection on display.sh of both players on port_player+2
	#note: launch on the file descriptor 5 and 6
	while :
	do
	        exec 5<>/dev/tcp/$IPPLAYER1/`expr $PORTPLAYER1 + 2`
	        test $? -eq 0 && break
		echo "Try again connect player 1 in 5s..."
	        sleep 5
	done
	while :
	do
	        exec 6<>/dev/tcp/$IPPLAYER2/`expr $PORTPLAYER2 + 2`
	        test $? -eq 0 && break
		echo "Try again connect player 2 in 5s..."
	        sleep 5
	done
	

	exec 8<> $fifo
	while :
	do
		read c <&8			#read informations written by two forks in the fifo
		
		state=0
		player=${c:1:1}			#identify the player
		parser_table			#update the table parsing it
	        #-----new ----
		case "${c:0:1}" in
	                "3") if [ ${posx[$player]} -lt $POSWIDTH ]; then
				modifier_table ${posx[$player]} ${posy[$player]} O
				let "posx[$player] += 1"
				modifier_table ${posx[$player]} ${posy[$player]} "$sym$player"
			     fi ;;
	                "4") if [ ${posx[$player]} -gt 0 ]; then
				modifier_table ${posx[$player]} ${posy[$player]} O
				let "posx[$player] -= 1"
				modifier_table ${posx[$player]} ${posy[$player]} "$sym$player"
			     fi ;;
	                "1") if [ ${posy[$player]} -gt 0 ];then
				modifier_table ${posx[$player]} ${posy[$player]} O
				let "posy[$player] -= 1"
				modifier_table ${posx[$player]} ${posy[$player]} "$sym$player"
			     fi ;;
	                "2") if [ ${posy[$player]} -lt $POSHEIGHT ]; then
				modifier_table ${posx[$player]} ${posy[$player]} O
				let "posy[$player] += 1"
				modifier_table ${posx[$player]} ${posy[$player]} "$sym$player"
			     fi ;;
			"w") if [ ${posy[$player]} -gt 0 ]; then	#in azerty replace w by z
				let "posshot= ${posy[$player]} - 1"
				modifier_table ${posx[$player]} $posshot w0
			     fi ;;
			"s") if [ ${posy[$player]} -lt $POSHEIGHT ]; then
				let "posshot= ${posy[$player]} + 1"
				modifier_table ${posx[$player]} $posshot s0
			     fi ;;
			"a") if [ ${posx[$player]} -gt 0 ]; then	#in azerty replace a by q
				let "posshot= ${posx[$player]} - 1"
				modifier_table $posshot ${posy[$player]} a0
			     fi ;;
			"d") if [ ${posx[$player]} -lt $POSWIDTH ]; then
				let "posshot= ${posx[$player]} + 1"
				modifier_table $posshot ${posy[$player]} d0
			     fi ;;
			*) #echo "other"
			    ;;
	        esac

		if [ $state -eq 1 ]; then		#send differents status depending of the player
			echo 1${table[*]} >&5
			echo 2${table[*]} >&6
		elif [ $state -eq 2 ]; then
			echo 2${table[*]} >&5
			echo 1${table[*]} >&6
		else
			echo $state${table[*]} >&5
			echo $state${table[*]} >&6
		fi
	done
	exec 8<&-
	exec 5<&-
	#above close files descriptors


elif [ "$1" = "fork" ]		#below the code of the fork
then
	fifodest=$2
	numplayer=$3
	fifosrc=/tmp/700$numplayer
	
	test -e $fifosrc || mkfifo $fifosrc
	
	netcat -l -p 700$numplayer >$fifosrc &		#launch netcat to listen on
	echo "errorlevel: $?"
	while :
	do
        	read c
		test "$c" != "" || continue		#continue if receive nothing
		echo $c$numplayer > $fifodest		#write into the shared fifo
	done <$fifosrc					#read from the fifo written by netcat
else
	echo "Proccessing issue"
	exit 1
fi


exit 0

