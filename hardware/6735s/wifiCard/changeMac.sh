ifconfig $1 down
macchanger -a $1
ifconfig $1 up
