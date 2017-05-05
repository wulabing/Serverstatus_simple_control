#!/bin/bash

#====================================================
#	System Request:Debian 7+/Ubuntu 14.04+/Centos 6+
#	Author:	wulabing
#	Dscription: Serverstatus_simple_control
#	Version: 1.0
# 	Blog: https://www.wulabing.com
#   	Special thanks: Toyo
#====================================================

sh_version="1.0"
web_directory="your website directory"
serverStatus_directory="/root/ServerStatus/server"

PID=`ps -ef| grep "sergate"| grep -v grep | awk '{print $2}'`

if [ ! -d "$web_directory" ]; then
	echo "please check out the web_directory,"
	exit
fi

if [ ! -d "$serverStatus_directory" ]; then
	echo "please check out the serverStatus_directory"
	exit
fi

case "$1" in
	start)
		if [ ! -z ${PID} ]; then
			echo "ServerStatus has already running"
		else
			cd "$serverStatus_directory"
				nohup ./sergate --config=config.json --web-dir="$web_directory" &
				sleep 1
				printf "\n"
				sleep 2
				echo "ServerStatus start" 

		fi
		;;
	stop)
		if [ ! -z ${PID} ]; then
			kill -9 ${PID} &>/dev/null
				if [ "$?" -eq 0 ]; then
					echo "the ServerStatus stop" 
				fi
		else
			echo "the ServerStatus is not running" 
			
		fi
		;;
	status)
		if [ ! -z ${PID} ]; then
			 echo "the server is running" 
		else
			 echo "the server is not running" 
		fi
		;;
	*)
		printf "USAGE:$0 {start|stop|status}\n"
esac
exit 
	
			
		
		
