#!/bin/bash

while [ `cat /tmp/ansible.$SAP_DEPLOYMENT-$IP.log | egrep -i "failed\=[^0]|unreachable\=[^0]|UNREACHABLE\!|ERROR\!" | wc -l` -ge 1 ]
do
   echo -e "Ansible deployment ERROR: \n `cat /tmp/ansible.$SAP_DEPLOYMENT-$IP.log | egrep -i "failed\=[^0]|unreachable\=[^0]|UNREACHABLE\!|ERROR\!"`";sleep 10

done

