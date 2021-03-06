#!/bin/bash

#====================================================
#	System Request:Debian 7+/Ubuntu 14.04+/Centos 6+
#	Author:	wulabing
#	Dscription: Serverstatus_simple_control
#	Version: 1.1.2
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


sh_version="1.1.2"
web_directory="your website directory"
serverStatus_directory="/root/ServerStatus/server"

PID=`ps -ef| grep "sergate"| grep -v grep | awk '{print $2}'`

if [ ! -d "$web_directory" ]; then
	echo -e "${Error} please check out the web_directory"
	exit 1
elif [ ! -f "${web_directory}/index.html" ]; then
	echo -e "${Error} Wrong web_directory"
	exit 1
fi

if [ ! -d "$serverStatus_directory" ]; then
	echo -e "${Error} please check out the serverStatus_directory"
	exit 1
elif [ ! -f "$serverStatus_directory/sergate" ]; then
	echo -e "${Error} Wrong serverStatus_directory"
	exit 1
fi

case "$1" in
	start)
		if [ ! -z ${PID} ]; then
			echo -e "${Notification} ServerStatus has already running"
		else
			cd "$serverStatus_directory"
				nohup ./sergate --config=config.json --web-dir="$web_directory" >/tmp/serverstatus.log &>/dev/null &
				if [ ! -z `ps -ef | grep "sergate"| grep -v grep | awk '{print $2}'` ]; then
					echo -e "${OK} ServerStatus start" 
					exit 0
				else
					echo -e "${Error} ServerStatus not running"
					exit 1
				fi

		fi
		;;
	stop)
		if [ ! -z ${PID} ]; then
			kill -9 ${PID} &>/dev/null
				if [ "$?" -eq 0 ]; then
					echo -e "${Notification} the ServerStatus stop" 
					exit 0
				else
					echo -e "${Error} ServerStatus stop FAIL"
					exit 1
				fi
		else
			echo -e "${Error} the ServerStatus is not running" 
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
	
			
		
		
