#!/bin/bash
#
#
#
#
###################################
#
#
#
###################################
echo "
 ██████╗ ██╗     ██████╗ ██╗██╗  ██╗██╗   ██╗███╗   ██╗████████╗███████╗██████╗
██╔════╝ ██║     ██╔══██╗██║██║  ██║██║   ██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗
██║  ███╗██║     ██████╔╝██║███████║██║   ██║██╔██╗ ██║   ██║   █████╗  ██████╔╝
██║   ██║██║     ██╔═══╝ ██║██╔══██║██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗
╚██████╔╝███████╗██║     ██║██║  ██║╚██████╔╝██║ ╚████║   ██║   ███████╗██║  ██║
 ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝
"
rm curltmp.txt > /dev/null 2>&1
rm ssltmp.txt > /dev/null 2>&1
rm nslookuptmp.txt > /dev/null 2>&1
rm domaintmp.txt > /dev/null 2>&1
rm ssltest.txt > /dev/null 2>&1
rm ssltmp.txt > /dev/null 2>&1
rm fqdn.txt > /dev/null 2>&1
cat glpi.txt |  while read output
do
    echo "check for $output"
    nslookup $output > nslookuptmp.txt
    domain=$(cat nslookuptmp.txt |awk '/name/{print $4}' | sed 's/.$//')
    echo "check for $domain"
    curl -k -IL https://$domain  --max-time 0,5 > ssltest.txt  2>&1 | grep "^HTTP\/"
    string0="HTTP/1.1 200 OK"
    if grep -qF "$string0" ssltest.txt;then
      fqdn=$(echo | openssl s_client -showcerts -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -inform pem -noout -text | grep Subject: | grep -o '[^,]\+$' | sed 's/^.*= //')
      # test if is it ok in httpS
      echo | openssl s_client -showcerts -servername $fqdn -connect $fqdn:443 2>/dev/null | openssl x509 -inform pem -noout -text > ssltmp.txt
      echo $fqdn > fqdn.txt
      var=$(grep glpi fqdn.txt)
      if [[ $var =~ glpi ]]
      then
          curl -k https://$fqdn --max-time 0,5 > curltmp.txt 2>&1
          string1="http://glpi-project.org/"
          if grep -qF "$string1" curltmp.txt;then
            echo "FOUND ! GLPI : https://$fqdn" >> glpi-server.txt
          fi
          curl -k https://$fqdn/glpi/ --max-time 0,5 > curltmp.txt 2>&1
          if grep -qF "$string1" curltmp.txt;then
            echo "FOUND ! GLPI : https://$fqdn/glpi/" >> glpi-server.txt
          fi
      fi
    else
      curl -k http://$domain --max-time 0,5 > curltmp.txt 2>&1
      string1="http://glpi-project.org/"
      if grep -qF "$string1" curltmp.txt;then
        echo "FOUND ! GLPI : http://$domain" >> glpi-server.txt
      fi
      curl -k http://$domain/glpi/ --max-time 0,5 > curltmp.txt 2>&1
      if grep -qF "$string1" curltmp.txt;then
        echo "FOUND ! GLPI : http://$domain/glpi/" >> glpi-server.txt
      fi
    fi
done
