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

cat glpi.txt |  while read output
do
    nslookup $output > nslookuptmp.txt
    domain=$(cat nslookuptmp.txt |awk '/name/{print $4}' | sed 's/.$//')
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
          curl -k https://$fqdn > curltmp.txt 2>&1
          string1="http://glpi-project.org/"
          if grep -qF "$string1" curltmp.txt;then
            echo "FOUND ! GLPI : https://$fqdn"
          fi
          curl -k https://$fqdn/glpi/ > curltmp.txt 2>&1
          if grep -qF "$string1" curltmp.txt;then
            echo "FOUND ! GLPI : https://$fqdn/glpi/"
          fi
      fi
    else
      curl http://$domain > curltmp.txt 2>&1
      string1="http://glpi-project.org/"
      if grep -qF "$string1" curltmp.txt;then
        echo "FOUND ! GLPI : http://$domain"
      fi
      curl http://$domain/glpi/ > curltmp.txt 2>&1
      if grep -qF "$string1" curltmp.txt;then
        echo "FOUND ! GLPI : http://$domain/glpi/"
      fi
    fi
done
