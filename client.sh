#!/bin/bash

#====================================================
#	System Request:Debian 7+/Ubuntu 14.04+/Centos 6+
#	Author:	wulabing
#	Dscription: Serverstatus_simple_control_client(include install)
#	Version: 2.0
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

sh_version="2.0"

# Modify by yourself!!
serverStatus_install_directory="/root"
serverStatus_direcotry="${serverStatus_install_directory}/ServerStatus"
serverStatus_client_directory="${serverStatus_direcotry}/clients"
client="client-linux.py"
# End

PID=`ps -ef| grep "${client}"| grep -v grep | awk '{print $2}'`

check_system(){
	if [[ -f /etc/redhat-system ]]; then
		system="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		system="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		system="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		system="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		system="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		system="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		system="centos"
	else 
		system="other"
	fi
}

dependency_install(){
	if [[ ${system} == "centos" ]]; then
		yum -y install git
	elif [[ ${system} == "debian" || ${system} == "ubuntu" ]]; then
		apt-get update
		apt-get -y install git
	else 
		echo -e "${Error} Don't Support this system"
	fi
}
client_linux_install(){
	cd ${serverStatus_install_directory}
	git clone https://github.com/tenyue/ServerStatus.git
	if [[ ! -d ${serverStatus_client_directory} ]]; then
		echo -e "${Error} git clone serverStaus FAIL"
		exit 1
	fi
}
client_psutil_install(){
	if [[ ${system} == "centos" ]]; then
		yum -y install epel-release
		[[ $? -ne 0 ]] && echo "${Error} install epel-release FAIL" && exit 1
		yum -y install python-pip
		[[ $? -ne 0 ]] && echo "${Error} install python-pip FAIL"  && exit 1
		yum clean all
		[[ $? -ne 0 ]] && echo "${Error} yum clean FAIL"  && exit 1
		yum -y install gcc
		[[ $? -ne 0 ]] && echo "${Error} install gcc FAIL"  && exit 1
		yum -y install python-devel
		[[ $? -ne 0 ]] && echo "${Error} install python-devel FAIL"  && exit 1
		pip install psutil
		[[ $? -ne 0 ]] && echo "${Error} pip install psutil FAIL"  && exit 1
	else
		apt-get -y install python-setuptools python-dev build-essential
		[[ $? -ne 0 ]] && echo "${Error} install python-setup FAIL"  && exit 1
		apt-get -y install build-essential
		[[ $? -ne 0 ]] && echo "${Error} install build-essential FAIL"  && exit 1
		apt-get -y install python-pip
		[[ $? -ne 0 ]] && echo "${Error} install python-pip FAIL"  && exit 1
		pip install psutil
		[[ $? -ne 0 ]] && echo "${Error} install psutil FAIL"  && exit 1
	fi
	client_linux_install
}


client_set(){
	stty erase '^H' && read -p "Server IP:" Server
	stty erase '^H' && read -p "Port(default:35601):" Port
	[[ -z ${Port} ]] && Port="35601"
	stty erase '^H' && read -p "User:" User
	stty erase '^H' && read -p "Password:" Password
	stty erase '^H' && read -p "Interval(default:1):" Interval
	[[ -z ${Interval} ]] && Interval="1"
}
modify_set(){
	sed -i '/SERVER = /c \SERVER = '\"${Server}\"'' ${serverStatus_client_directory}/${client}
	sed -i '/PORT = /c \PORT = '${Port}'' ${serverStatus_client_directory}/${client}
	sed -i '/USER = /c \USER = '\"${User}\"'' ${serverStatus_client_directory}/${client}
	sed -i '/PASSWORD = /c \PASSWORD = '\"${Password}\"'' ${serverStatus_client_directory}/${client}
	sed -i '/INTERVAL = /c \INTERVAL = '${Interval}'' ${serverStatus_client_directory}/${client}
}
select_version(){
	echo -e "1.client-linux"
	echo -e "2.client-psutil"
	stty erase '^H' && read -p "Please select which one to install(default:1):" client
	if [[ -z ${client} || ${client} == "1" ]]; then
		client="client-linux.py"
	elif [[ ${client} == "2" ]]; then
		client="client-psutil.py"
	else
		echo -e "${Error} you can only select in 1 or 2"
		exit 1
	fi
}
isInstall(){
	if [[ ! -d ${serverStatus_direcotry} ]]; then
		echo -e "${Error} The service is not installed "
		exit 1
	fi
}
Uninstall(){
	isInstall
	rm -rf ${serverStatus_direcotry}
	[[ ! -d ${serverStatus_direcotry} ]] && echo -e "${Notification} The service uninstalled successfully"	
}

case "$1" in
	start)
		if [ ! -z ${PID} ]; then
			echo -e "${Notification} client has already running"
		else
			cd "$serverStatus_client_directory"
				nohup python ${client} &>/dev/null &
				if [ ! -z `ps -ef | grep "${client}"| grep -v grep | awk '{print $2}'` ]; then
					echo -e "${OK} client start successfully" 
					exit 0
				else
					echo -e "${Error} client is not running"
					exit 1
				fi

		fi
		;;
	stop)
		if [ ! -z ${PID} ]; then
			kill -9 ${PID} &>/dev/null
				if [ "$?" -eq 0 ]; then
					echo -e "${Notification} the client stop SUCESS" 
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
	install)
		check_system
		select_version 
		client_set
		if [[ ${client} == "client-linux.py" ]]; then
			client_linux_install
		else
			client_psutil_install
		fi

		modify_set
		echo -e "${OK} install ${client} successfully" 
		;;
	uninstall)
		Uninstall
		;;
	*)
		echo -e "${Notification} USAGE:$0 {start|stop|status|install|uninstall}"
esac
exit 
	
			
		
		
