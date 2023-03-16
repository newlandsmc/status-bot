#!/bin/bash

botToken="OTUwNDcxMTMxOTM1MTc0NjU2.GiYi8J.ic7q4R4Yq-wZbTkXdD3QzJosayDqUSJFEMf8wo"
channel="https://discord.com/api/channels/1080752312122867722"
playersMessage="1080792621796032512"
categoryChannel="https://discord.com/api/channels/1080752233509040128"

######################
#Do seomthing
######################

playerCount=0
playerList=""

for i in $(curl -s localhost:9985/metrics | grep -oP '.*player=\"\K[\w\d_-]+(?=)')
do
  ((playerCount++))
  if [[ $playerList == "" ]]
  then
    playerList="$i"
  else
    playerList="$playerList, $i"
  fi
done

echo $playerCount
echo $playerList
