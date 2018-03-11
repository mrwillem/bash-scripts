#!/bin/bash

# This is a short script that checks whether a job is queued in BAREOS
# it returns 1 if a job is running or waiting to be run and otherwise 0
echo "status dir" | /usr/sbin/bconsole  -c /etc/bareos/bconsole.conf  | grep running 
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
	exit 1
fi
echo "status dir" | /usr/sbin/bconsole  -c /etc/bareos/bconsole.conf  | grep waiting
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
	exit 1
fi
echo "status dir" | /usr/sbin/bconsole  -c /etc/bareos/bconsole.conf  | grep "waiting ex"
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
	exit 1
fi
echo "status dir" | /usr/sbin/bconsole  -c /etc/bareos/bconsole.conf  | grep "waiting on"
RETVAL=$?
if [ $RETVAL -eq 0]; then
	exit 1
fi
exit 0
