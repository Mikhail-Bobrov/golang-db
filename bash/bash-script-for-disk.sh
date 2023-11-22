#!/bin/bash
y=$(sudo  pvs -a | grep /dev/s | wc -l)
echo $y
for (( i=1; i <=$y; i++ ))
do
        x=$(pvs -a | grep /dev/s | awk '{print $1}' | sed -n "${i}p")
        echo $x
	result=$(smartctl -Hc $x | grep result:)
	echo $result
	beta=$( sudo smartctl -H $x  | awk '{print $6}' | grep PASSED)
	if [[ $beta =  "PASSED" ]]
	then
		echo ""
	else
		udevadm info --query=all --name="${x}"  | grep ID_SERIAL_SHORT
                smartctl -Hc $x | grep "Failed Attributes:" -A 3
		echo ""
	fi
done
