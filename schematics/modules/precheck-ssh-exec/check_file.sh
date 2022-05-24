#!/bin/bash

for FILE in ${@}
do
  if [[ ! -f $FILE ]]
  then
    echo -e "ERROR! \n The PATH ${FILE} does not exist!"
  fi
done
