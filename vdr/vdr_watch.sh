#!/bin/bash
# A Daemon that checks if a vdr client host is up every ten seconds and starts the vdr server if necessary
# Variables
# LOGFILE: File used for logging output
# CLIENT: The TV Client


TIMER=0
CHANNELSCAN=0
STATUS=0
LOGFILE=/var/log/vdr_reload.log
CLIENT=teevee.crossbone.org

/etc/vdr/vdr_reload.sh stop
while true; do
	DATE=`date`
	if [ -f /etc/vdr/timer_active ]; then
		TIMER=1
		if [ $STATUS -eq 0 ]; then
			echo "$DATE Starting vdr because of timer" >> $LOGFILE
			/etc/vdr/vdr_reload.sh start
			STATUS=1
		fi
	else
		TIMER=0
	fi
	HOUR=`date +%H`
	if [ $HOUR -eq 04 ]; then
		CHANNELSCAN=1
		echo "$DATE Starting vdr because of CHANNELSCAN" >> $LOGFILE
		/etc/vdr/vdr_reload.sh start
		STATUS=1
	else
		CHANNELSCAN=0
	fi
	
	if [ $TIMER -eq 0 ]; then
		if [ $CHANNELSCAN -eq 0 ]; then
			ping -c2 $CLIENT
			RET=$?
			if [ $RET -eq 0 ]; then
				if [ $STATUS -eq 0 ]; then
					echo "$DATE Starting vdr because of client request" >> $LOGFILE
					/etc/vdr/vdr_reload.sh start
					STATUS=1
				else
					echo "$DATE VDR should be running... do nothing" >> $LOGFILE
				fi
			else
				if [ $STATUS -eq 1 ]; then
					echo "$DATE Killing VDR.... It is not needed to be running" >> $LOGFILE
					/etc/vdr/vdr_reload.sh stop
					STATUS=0
				else
					echo "$DATE VDR is not running.... do nothing" >> $LOGFILE
				fi
			fi
		fi
	fi
	sleep 10
done
