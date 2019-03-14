#!/bin/sh

t=`dig www.litmix.es | grep floating`
b=hi
i=0

while [ "${t:-0}" == 0 ];
do
  clear
  echo "Checking for $i seconds..."
  i=`expr $i + 1`
  t=`dig www.litmix.es | grep floating`
  sleep 1
done

echo "Found!"
