#!/bin/bash
#
#
#
##################
#
#
#
##################
echo "USAGE : ./scan.sh 192.168.1.0/24"
rm srvlist.txt
rm liste_open.txt
nmap -p 80,443 $1 > srvlist.txt
grep -B 4 open srvlist.txt  >> liste_open.txt
grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" liste_open.txt >> glpi.txt
rm srvlist.txt
rm liste_open.txt
