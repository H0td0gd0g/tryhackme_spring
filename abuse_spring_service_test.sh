#!/bin/bash

epoch=$(date +%s)

curl -X 'POST' -H 'Content-Type: application/json' -H 'x-9ad42dea0356cb04: 172.16.0.1' 'https://localhost/actuator/shutdown' -k

for  i  in {1..30}
 do 
 time=$(( epoch + i )) 
 ln -sf /home/johnsmith/test.txt /home/johnsmith/tomcatlogs/$time.log 
 done