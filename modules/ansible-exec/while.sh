#!/bin/bash

while [ `ps -ef | grep $SAP_DEPLOYMENT-$IP | wc -l` -gt 1 ]
do
   tail /tmp/ansible.$SAP_DEPLOYMENT-$IP.log; sleep 10
   if [ `ps -ef | grep $SAP_DEPLOYMENT-$IP | wc -l` -eq 1 ]
   then
      break
   else
      tail /tmp/ansible.$SAP_DEPLOYMENT-$IP.log; sleep 10
   fi
done
