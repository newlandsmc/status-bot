#!/bin/bash

botToken="OTUwNDcxMTMxOTM1MTc0NjU2.GiYi8J.ic7q4R4Yq-wZbTkXdD3QzJosayDqUSJFEMf8wo"
statusChannel="https://discord.com/api/channels/1080752312122867722"
categoryChannel="https://discord.com/api/channels/1080752233509040128"
color="14559272"
uptime="NA"
state="UNKNOWN"
playerCount=0
globalCount=0
playerList=""
dateFormat=$(date +"%B %d %H:%M%Z")

function=$1
server=$2
service_result=$3
exit_code=$4
exit_status=$5

if [ $server == "lobby" ]
then
  messageID="1080792638950756384"
  directory="lobby"
elif [ $server == "survival" ]
then
  messageID="1080792645028302918"
  directory="survival"
elif [ $server == "creative" ]
then
  messageID="1080794030868283422"
  directory="creative"
elif [ $server == "proxy" ]
then
  messageID="1080792631124164628"
  directory="proxy"
fi

getState () {
  state=$(systemctl show $server -P ActiveState | awk '{print toupper($0)}')
  stateChangeTime=$(date +"%B %d %H:%M%Z" -d "$(systemctl show $server -P StateChangeTimestamp)")
  if [ $state == "ACTIVE" ]
  then
    color="56137"
    uptimeTotal=$(($(date -d "$dateFormat" +%s) - $(date -d "$stateChangeTime" +%s)))
    uptimeMinutes=$((($uptimeTotal/(60))%60))
    uptimeHours=$((($uptimeTotal/(60*60))%24))
    uptime="$uptimeHours hours $uptimeMinutes minutes"
  elif [ $state == "ACTIVATING" ] || [ $state == "DEACTIVATING" ]
  then
    color="15135241"
    uptimeTotal=$(($(date -d "$dateFormat" +%s) - $(date -d "$stateChangeTime" +%s)))
    uptimeMinutes=$((($uptimeTotal/(60))%60))
    uptimeHours=$((($uptimeTotal/(60*60))%24))
    uptime="$uptimeHours hours $uptimeMinutes minutes"
  fi
}

globalStatus () {
  for i in $(curl -s localhost:9985/metrics | grep -oP ".*player=\"\K[\w\d_-]+(?=)")
  do
    ((globalCount++))
  done
  curl -s -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "{\"name\":\"PLAYERS ONLINE: $globalCount\"}" $categoryChannel > /dev/null
}

getPlayers () {
  for i in $(curl -s localhost:9985/metrics | grep -oP ".*$server.*player=\"\K[\w\d_-]+(?=)")
  do
    ((playerCount++))
    if [[ $playerList == "" ]]
    then
      playerList="$i"
    else
      playerList="$playerList, $i"
    fi
  done
}

apiCall () {
  cycles=1
  while [ $cycles -le 3 ]
  do
    response=$(curl -s -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "{\"embeds\":[{\"title\":\"$(echo $server | awk '{print toupper($0)}') : $state\",\"description\":\"Uptime: $uptime\nPlayers: $playerCount ($playerList)\nLast Ping: $dateFormat\",\"color\":\"$color\"}]}" $statusChannel/messages/$messageID)
    if [ "$(echo $response | jq '.code')" == "30046" ]
    then
      cycles=$((cycles + 1))
      sleep 10
    else
      cycles=4
    fi
  done
}

updateServer () {
 getState
 getPlayers
 apiCall 
}

startServer () {
  getState
  apiCall
  cycles2=1
  while [ $cycles2 -le 30 ]
  do
    getState
    if [ $state == "ACTIVE" ]
    then
      apiCall
      cycles2=6
    else
      cycles2=$((cycles2 + 1))
      sleep 2
    fi
  done
}

stopServer () {
  globalStatus
  getState
  apiCall
}

$function
