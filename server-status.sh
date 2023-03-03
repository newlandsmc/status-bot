#!/bin/bash

botToken="OTUwNDcxMTMxOTM1MTc0NjU2.GiYi8J.ic7q4R4Yq-wZbTkXdD3QzJosayDqUSJFEMf8wo"
statusChannel="https://discord.com/api/channels/1080752312122867722"

function=$1
server=$2
service_result=$3
exit_code=$4
exit_status=$5

dateFormat=$(date +"%B %d %H:%M%Z")

if [ $server == "Lobby" ]
then
  messageID="1080792638950756384"
  directory="lobby"
elif [ $server == "Survival" ]
then
  messageID="1080792645028302918"
  directory="survival"
elif [ $server == "Creative" ]
then
  messageID="1080794030868283422"
  directory="creative"
elif [ $server == "Proxy" ]
then
  messageID="1080792631124164628"
  directory="proxy"
fi

startServer () {
  curl -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "{\"embeds\":[{\"title\":\"$server : UP\",\"description\":\"Start time: $dateFormat\",\"color\":\"56137\"}]}" $statusChannel/messages/$messageID
  #curl -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "{\"embeds\":[{\"title\":\"$server\",\"description\":\"$server is running.\nSince: $dateFormat\n\nPlayers: 0\",\"color\":\"56137\"}]}" $statusChannel/messages/$messageID
}

stopServer () {
  curl -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "{\"embeds\":[{\"title\":\"$server : DOWN\",\"description\":\"Stop time: $dateFormat\nExit Code: $exit_code\",\"color\":\"14559272\"}]}" $statusChannel/messages/$messageID
  #curl -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "{\"embeds\":[{\"title\":\"$server\",\"description\":\"$server is stopped.\nSince: $dateFormat\nExit Code: $exit_code\n\nPlayers: 0\",\"color\":\"14559272\"}]}" $statusChannel/messages/$messageID
}

#BROKEN DOESN"T WORK RIGHT NOW
updateServer () {
  currentMessage=$(curl -s -X GET -H "Authorization: Bot $botToken" -H "Content-Type: application/json" $statusChannel/messages/$messageID)
  getPlayers=$(/var/minecraft/$directory/run.sh "minecraft:list" | sed "s/.*: //")
  newDescription=$(echo $currentMessage | jq '.embeds[0].description' | sed "s/Players: [^\"]*/Players: $getPlayers/")
  newMessage=$(echo $currentMessage | jq 'del(.embeds[0].description)')
  newMessage=$(echo $currentMessage | jq ".embeds[0] += {""description"":""$newDescription""}")
  curl -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "$newMessage" $statusChannel/messages/$messageID
}

$function
