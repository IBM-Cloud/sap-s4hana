#!/bin/bash
TIMEOUT=$(( $ANSIBLE_TIMEOUT * 60 - 1))
SCHEMATICS_TIMEOUT=$(($ANSIBLE_TIMEOUT *5))
PID=$(ps -ef | grep $SAP_DEPLOYMENT | grep $IP |awk '{print $2}' | head -n 1)

if [ -z "$PID" ]
   then
      echo "No TIMEOUT detected!"
   else
      TIME=$(ps -eo pid,cmd,etimes |  grep $PID  | head -n 1 | awk '{print $3}')
      # echo -e "Ansible deployment time: $(($TIME / 60)) Minutes"
      echo -e "Total SAP Schematics Timeout: $SCHEMATICS_TIMEOUT Minutes"
      echo "Ansible PID: $PID"
      while (( $TIME >= $TIMEOUT ))
         do
            echo -e "Ansible deployment TIMEOUT ERROR!! \n Check your input variables and /tmp/ansible.$SAP_DEPLOYMENT-$IP.log";sleep 10

      done
fi
