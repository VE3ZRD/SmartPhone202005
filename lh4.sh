#!/bin/bash
#################################################
#  Get Last Heard Liost from MMDVMHost Log	#
#						#
#						#
#  VE3RD 			2020-05-03	#
#################################################
set -o errexit
set -o pipefail
sudo mount -o remount,rw /


CallN2=""
CallRF1=""
CallRF2=""
Mode="N/A"


f1=$(ls -tr /var/log/pi-star/MMDVM* | tail -1)
#echo "File: $f1"
#MList=$(sudo sed -n '/received/p' $f1 | sed 's/,//g' | sort -k2,3 | tail -2)
MList=$(sudo sed -n '/received/p' $f1 | sed 's/,//g' | tail -1)
MList2=$(sudo sed -n '/watchdog/p' $f1 | sed 's/,//g' | tail -1)

TG=$(echo "$MList" | head -1 | awk '{print $14}')
BER=$(echo "$MList" | head -1 | awk '{print $18}')

if [ ! "$BER" == "BER" ]; then
	BER=$(echo "$MList" | head -1 | awk '{print $23}')
fi


Modes=$(echo "$MList" | head -1 | awk '{print $8}')

if [ "$Modes" == "network" ]; then
	Modes="Net"
fi
if [ "$TG" == "TG" ]; then
  	mode="$Modes""1"
elif [ "$BER" == "BER:" ]; then
  	mode="$Modes""2"
elif [ "$TOList" ]; then
  mode="Net3"
fi

list3=$(echo "$MList" | head -1 | awk '{print substr($2,6,5),substr($3,0,6),$12,$15}')
list4=$(echo "$MList" | tail -1 | awk '{print substr($2,6,5),substr($3,0,6),$14,$6,$17,$18,$20,$21,$23}')
TOList=$(echo "$MList2" | tail -1 | awk '{print substr($2,6,5),substr($3,0,6),$11,$13}')
if [ "$mode" == "RF1" ]; then
		call=$(echo "$MList" | awk '{print $12}')
		TG=$(echo "$list3" | awk '{print $4}')

elif [ "$mode" == "RF2" ]; then
		call=$(echo "$MList" | awk '{print $14}')
		TG=$(echo "$list4" | awk '{print $5}')

elif [ "$mode" == "Net1" ]; then
		call=$(echo "$MList" | awk '{print $12}')
		TG=$(echo "$list3" | awk '{print $4}')

elif [ "$mode" == "Net2" ]; then
		call=$(echo "$MList" | awk '{print $14}')
		TG=$(echo "$list4" | awk '{print $5}')

elif [ "$mode" == "Net3" ]; then
		call=$(echo "$MList" | awk '{print $14}')
		TG=$(echo "$list4" | awk '{print $5}')

fi


tLine=$(sudo sed -n "/$call/p" /home/pi-star/SmartPhone/user.csv  | head -1)

city=$(echo "$tLine" | cut -d',' -f5)
prov=$(echo "$tLine" | cut -d',' -f6)
cntry=$(echo "$tLine" | cut -d',' -f7)
fname=$(echo "$tLine" | cut -d',' -f3)
lname=$(echo "$tLine" | cut -d',' -f4)
did=$(echo "$tLine" | cut -d',' -f1)
name="$fname $lname" 
#echo "$cntry"
        DT=$(echo "$list4" | awk '{print $1}')
	TM=$(echo "$list4" | awk '{print $2}')

        TS=$(echo "$list4" | awk '{print $4}')
        Sec=$(echo "$list4" | awk '{print $6}')
        PLoss=$(echo "$list4" | awk '{print $7}')
	ber=$(echo "$list4" | awk '{print $8}')
	rssi=$(echo "$list4" | awk '{print $9}')



if [ "$1" == "2" ]; then
        printf "3\n%s %s %s %s \nID=%s TG=%s TS=%s \nDur=%s PLoss=%s \n" "$DT" "$TM" "$call" "$name" "$did" "$TG" "$TS" "$Sec" "$PLoss"
#        printf "3\n$DT $TM $call $name ID=$did TG=$TG"

else
	if [ "$mode" = "Net1" ]; then
			printf "1\n$call, $name $did \nTG=$TG, TS=$TS, $city, \n$prov, $cntry\n"
	elif [ "$mode" = "Net2" ]; then
			printf "2\n%s %s ID=%s \n%s, %s, %s, \n%s %s, TG=%s, TS=%s, Sec=%s, Ploss=%s \n" "$call" "$name" "$did" "$city" "$prov" "$cntry" "$DT" "$TM" "$TG" "$TS" "$Sec" "$PLoss"
	elif [ "$mode" = "Net3" ]; then
			printf "4\n$call, $name $did \nTG=$TG, TS=$TS, $city, \n$prov, $cntry\n"
	elif [ "$mode" = "RF1" ]; then
			printf "1\n%s %s ID=%s \nTG=%s TS=%s\n" "$call" "$name" "$did" "$TG" "$TS"
	elif [ "$mode" = "RF2" ]; then
			printf "2\n%s %s ID=%s \nTG=%s TS=%s Dur=%s Ber=%s Rssi=%s\n" "$call" "$name" "$did" "$TG" "$TS" "$Sec" "$ber" "$rssi"

	else
		# [ "$mode" = "Net1" ]; then

			printf "3\n%s ber=%s rssi=%s\n" "$call" "$ber" "$rssi" 
	fi

fi



