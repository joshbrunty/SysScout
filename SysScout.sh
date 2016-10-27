#!/bin/bash

# SysScout - A simple menu driven shell script to get information about your 
# Linux-based System.
# Author: Josh Brunty [josh dot brunty at marshall dot edu]
# Date: 16September2016
# Version 1.0.1
# Updated 27October2016
# https//github.com/joshbrunty/SysScout

# Define variables

# Display pause prompt
# $1-> Message (optional)
function pause(){
	local message="$@"
	[ -z $message ] && message="Press [Enter] key to continue..."
	read -p "$message" readEnterKey
}

# Display the startup menu on screen
function show_menu(){
    echo "-------------------------------------------"
    echo "
   _____               _____                     _   
  / ____|             / ____|                   | |  
 | (___   _   _  ___ | (___    ___  ___   _   _ | |_ 
  \___ \ | | | |/ __| \___ \  / __|/ _ \ | | | || __|
  ____) || |_| |\__ \ ____) || (__| (_) || |_| || |_ 
 |_____/  \__, ||___/|_____/  \___|\___/  \__,_| \__|
           __/ |                                     
          |___/                                 "
    echo "-------------------------------------------"

echo "A Network Forensics/Incident Response Tool"
echo "By: Josh Brunty [josh dot brunty at marshall dot edu]"

    echo "-------------------------------------------"
    echo "Current Local Machine Date & Time : $(date)"
    echo "---------------------------"
    echo "   Main Menu"
    echo "---------------------------"
	echo "1. Operating System Info"
	echo "2. HOST and DNS Info"
	echo "3. Network Info"
	echo "4. Who is Online"
	echo "5. Last Logged In Users"
	echo "6. Memory Information"
	echo "7. Exit"
}

# Display the header message
# $1 - message
function write_header(){
	local h="$@"
	echo "---------------------------------------------------------------"
	echo "     ${h}"
	echo "---------------------------------------------------------------"
}

# Get info about Local Machine Operating System
function os_info(){
	write_header " Operating System Information "
	echo "Operating system : $(uname -no)"
	echo "Operating System Version : $(uname -mv)"
	#pause "Press [Enter] key to continue..."
	pause
}

# Get information about localhost 
function host_info(){
	local dnsips=$(sed -e '/^$/d' /etc/resolv.conf | awk '{if (tolower($1)=="nameserver") print $2}')
	write_header " Hostname and DNS information "
	echo "Hostname : $(hostname -s)"
	echo "DNS domain : $(hostname -d)"
	echo "Fully qualified domain name : $(hostname -f)"
	echo "Network address (IP) :  $(hostname -i)"
	echo "DNS name servers (DNS IP) : ${dnsips}"
	pause
}

# Network Inferface/Routing/MAC Address info (i.e. IP & NetStat)
function net_info(){
	devices=$(netstat -i | cut -d" " -f1 | egrep -v "^Kernel|Iface|lo")
	write_header " Network information "
	echo "Total network interfaces found : $(wc -w <<<${devices})"

	echo "***********************"
	echo "*** IP Address Info***"
	echo "***********************"
	ip -4 address show

	echo "***********************"
	echo "*** Network Routing ***"
	echo "***********************"
	netstat -nr

	echo "**************************************"
	echo "*** Interface Traffic information ***"
	echo "**************************************"
	netstat -i

	echo "***********************"
	echo "*** MAC/Hardware Addresses ***"
	echo "***********************"
	cat /sys/class/net/*/address
	pause 
}

# Display a list of users currently logged on 
# Display a list of recently logged in users   
function user_info(){
	local cmd="$1"
	case "$cmd" in 
		who) write_header " Who is online "; who -H; pause ;;
		last) write_header " List of last logged in users "; last ; pause ;;
	esac 
}

# Display used and free memory info
function mem_info(){
	write_header " Free and used memory "
	free -m
    
    echo "*********************************"
	echo "*** Virtual Memory Statistics ***"
    echo "*********************************"
	vmstat
    echo "***********************************"
	echo "*** Top 5 Memory Utilizing Processes ***"
    echo "***********************************"	
	ps auxf | sort -nr -k 4 | head -5	
	pause
}
# Get input via the keyboard and make a decision. 
function read_input(){
	local c
	read -p "Enter your choice [ 1 - 7 ] " c
	case $c in
		1)	os_info ;;
		2)	host_info ;;
		3)	net_info ;;
		4)	user_info "who" ;;
		5)	user_info "last" ;;
		6)	mem_info ;;
		7)	echo "Happy Forensicating. Go Herd!!!"; exit 0 ;;
		*)	
			echo "Please select between 1 to 8"
			pause
	esac
}

# ignore CTRL+C, CTRL+Z and quit singles using the trap command.  This prohibits interrupts
trap '' SIGINT SIGQUIT SIGTSTP

# logic for program input
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done
