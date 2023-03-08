#!/bin/bash

botToken="OTUwNDcxMTMxOTM1MTc0NjU2.GiYi8J.ic7q4R4Yq-wZbTkXdD3QzJosayDqUSJFEMf8wo"
channel="https://discord.com/api/channels/1080752312122867722"
playersMessage="1080792621796032512"
categoryChannel="https://discord.com/api/channels/1080752233509040128"

######################
#Make initial API calls and save to variable
######################
javaAPI=$(curl -s https://api.mcsrvstat.us/2/play.newlandsmc.com)
bedrockAPI=$(curl -s https://api.mcsrvstat.us/bedrock/2/play.newlandsmc.com)

######################
#Get if servers are online or unreachable
######################
if [ $(echo $javaAPI | jq '.online') == true ]
then
  javaStatus="Online"
else
  javaStatus="Unreachable"
fi
if [ $(echo $bedrockAPI | jq '.online') == true ]
then
  bedrockStatus="Online"
else
  bedrockStatus="Unreachable"
fi

if [ $bedrockStatus == "Online" ] && [ $javaStatus == "Online" ]
then
  globalStatus="HEALTHY"
  color="56137"
elif [ $bedrockStatus == "Online" ] || [ $javaStatus == "Online" ]
then
  globalStatus="UNHEALTHY"
  color="15135241"
else
  globalStatus="DEAD"
  color="14559272"
fi

######################
#Get list of players online
######################
playersOnline=$(echo $javaAPI | jq '.players.online')

players="Nobody is currently online..."
count=0
while [ $count -lt $playersOnline ]
do
  userName=$(echo $javaAPI | jq ".players.list[$count]" -r)
  if [ ! "$players" == "Nobody is currently online..." ]
  then
    players="$players, $userName"
  else
    players="Players: $userName"
  fi
  ((count++))
done

######################
#Get cachetime and save to variable
######################
cacheTime=$(echo $javaAPI | jq '.debug.cachetime' -r)
if [ $cacheTime -eq 0 ]
then
  cacheFormat="unknown"
else
  cacheFormat=$(echo $cacheTime | xargs -i date +"%B %d %H:%M%Z" -d@{})
fi

######################
#Send Discord API calls
######################
payload="{\"embeds\":[{\"description\":\"Java: $javaStatus\nBedrock: $bedrockStatus\n$players\nLast Ping: $cacheFormat\",\"title\":\"EXTERNAL STATUS: $globalStatus\",\"color\":\"$color\"}]}"
cycles=1
while [ $cycles -le 3 ]
do
  respone=$(curl -s -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "$payload" $channel/messages/$playersMessage)
  if [ "$(echo $response | jq '.code')" == "30046" ]
  then
    cycles=$((cycles + 1))
    sleep 10
  else
    cycles=4
  fi
done
curl -s -X PATCH -H "Authorization: Bot $botToken" -H "Content-Type: application/json" -d "{\"name\":\"PLAYERS ONLINE: $playersOnline\"}" $categoryChannel > /dev/null
