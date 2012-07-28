Bash-network-game
=================

This project is a fully working 2 player network game written in bash. It intents to show the possibilities of bash which is not a simple script program.
You can find a complete blog post about it here: http://robindavid.comli.com/network-game-in-bash/
The goal of this project is to show the capabilities of bash by doing a game fully in bash.

Requirements
------------

* Netcat: Netcat is used to perform the network communication.
* Dialog: This is a curse program that allow to show dialog windows in console

What is the goal of the game?
-----------------------------

The goal of the game is simply to shot the other player.
ZSQD are the keyboard keys to move and the arrows to shot (front, back, left or right)

How it works ?
--------------

The only things to know is that is bash so the code is quite dirty but working (most of the case :p).
Basically there is the server script that should be launch by one of the two players.
Then players should have two consoles one to launch keyboard that will listen for keys and display
that will shows the map.
Note: Display is a server and the server script will connect to it to stream the map to the two players.

How to play ?
-------------

Play is quite tricky because scripts should be launched in a specific order.
1. First the server should be launched by one of the two peers.
2. The two players should have the display script running waiting for connection.
3. The first player should launch keyboard with the right server ip and port
4. The second player should launch keyboard with the right server ip port

Let's play !