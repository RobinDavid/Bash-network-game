
![Game image](https://raw.github.com/RobinDavid/Bash-network-game/master/snapshot.jpg)

Bash-network-game
=================

This project is 2 player network proof of concept game written in bash.
The goal of this project is to show the capabilities of bash by doing a game fully in bash.

Features used:
* two dimension arrays emulation
* network communication (with netcat)
* multiple file descriptors usage
* process communication using fifo files
* "self forking"

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

Files are:
1. *keyboard.sh*: script which send key typed to the server. It takes in argument the IP and the port of the server to connect to.
2. *server.sh*: The most important script, it receive key typed by the two gamers, compute all collisions operations and sned the resulting matrix, back to gamers on the other port. (So it should take both players IP to work)
3. *display.sh*: basically just receive the matrix calculated by the server and print it using dialog command. It takes the port on which listening in argument.

Basically there is the server script that should be launch by one of the two players.
Then players should have two consoles one to launch keyboard that will listen for keys and display
that will shows the map.
Note: Display is a server and the server script will connect to it to stream the map to the two players.

By default ports used are 7001 and 7002 for players keyboards and the server connect to the port 7003 and 7004 of the players.

![process interaction](https://raw.github.com/RobinDavid/Bash-network-game/master/archi.jpg)

How to play ?
-------------

Play is quite tricky because scripts should be launched in a specific order.
1. First the server should be launched by one of the two peers.
2. The two players should have the display script running waiting for connection.
3. The first player should launch keyboard with the right server ip and port
4. The second player should launch keyboard with the right server ip port

Let's play !
