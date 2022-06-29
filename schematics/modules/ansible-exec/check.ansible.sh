#!/bin/sh

while [ `ps -ef | grep $SAP_DEPLOYMENT-$IP | wc -l` -eq 1 ]
do
   echo "Waiting for ansible processes to start"; sleep 10
   if [ `ps -ef | grep $SAP_DEPLOYMENT-$IP | wc -l` -gt 1 ]
   then
      break
   else
      echo "Waiting for ansible processes to start"; sleep 10
   fi
done
