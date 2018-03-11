#!/bin/bash


case $1 in 
stop)
	/etc/init.d/vdr stop
	# Ask the server to terminate
	killall -TERM vdr
	sleep 10
	# If the server does not terminate after 10 seconds force to kill the server
	killall -KILL vdr
	sleep 10
	# Unload the kernel modules. 
	# If the modules are loaded longer than a few hours the hardware does not work properly
	rmmod cx23885
	# Sleep another four seconds. 
	# Just to make shure the module is unloaded if another start command follows immediately.
	sleep 4
;;
start)
	modprobe cx23885
	/etc/init.d/vdr start
;;

esac
