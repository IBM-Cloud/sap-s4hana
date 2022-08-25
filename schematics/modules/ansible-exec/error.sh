#!/bin/sh

while [ `cat /tmp/ansible.$SAP_DEPLOYMENT-$IP/ansible.$IP.log | egrep -i "failed\=[^0]|unreachable\=[^0]" | wc -l` -ge 1 ]
do
   echo -e "Ansible deployment ERROR: \n `cat /tmp/ansible.$SAP_DEPLOYMENT-$IP/ansible.$IP.log | egrep -i "failed\=[^0]|unreachable\=[^0]"` \n  `tail -3 /tmp/ansible.$SAP_DEPLOYMENT-$IP/ansible.$IP.log`";sleep 5

done
