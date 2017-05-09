#!/bin/bash

#====================================================
#	System Request:Debian 7+/Ubuntu 14.04+/Centos 6+
#	Author:	wulabing
#	Dscription: Serverstatus_simple_control_client
#	Version: 1.0
# 	Blog: https://www.wulabing.com
#	Special thanks: Toyo
#====================================================

#fonts color
Green="\033[32m" 
Red="\033[31m" 
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"


#notification information
Info="${Green}[Info]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[Error]${Font}"
Notification="${Yellow}[Notification]${Font}"


sh_version="1.0"
serverStatus_client_directory="/root/ServerStatus/clients"
client="client-linux.py"

PID=`ps -ef| grep "${client}"| grep -v grep | awk '{print $2}'`


if [ ! -f "$serverStatus_client_directory/${client}" ]; then
	echo -e "${Error} Wrong directory"
	exit 1
fi

case "$1" in
	start)
		if [ ! -z ${PID} ]; then
			echo -e "${Notification} client has already running"
		else
			cd "$serverStatus_client_directory"
				nohup python ${client} &>/dev/null &
				if [ ! -z `ps -ef | grep "${client}"| grep -v grep | awk '{print $2}'` ]; then
					echo -e "${OK} client start" 
					exit 0
				else
					echo -e "${Error} client not running"
					exit 1
				fi

		fi
		;;
	stop)
		if [ ! -z ${PID} ]; then
			kill -9 ${PID} &>/dev/null
				if [ "$?" -eq 0 ]; then
					echo -e "${Notification} the client stop" 
					exit 0
				else
					echo -e "${Error} client stop FAIL"
					exit 1
				fi
		else
			echo -e "${Error} the client is not running" 
			exit 1
			
		fi
		;;
	status)
		if [ ! -z ${PID} ]; then
			 echo -e "${OK} the server is running" 
			 exit 0
		else
			 echo -e "${Notification} the server is not running" 
			 exit 1
		fi
		;;
	*)
		printf "USAGE:$0 {start|stop|status}\n"
esac
exit 
	
			
		
		
