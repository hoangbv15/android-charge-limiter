USB_HUB=0-1.1.3
USB_PORT=1
CHARGE_STOP_LEVEL=80

IS_CHARGING=1

# adb root
function setUsbPower {
	IS_CHARGING=$1
	uhubctl -l $USB_HUB -a $1 -p $USB_PORT > /dev/null
}

function getBatteryLevel {
	adb shell dumpsys battery get level
}

function backOff {
	local pause=$1
	local step=$((3/2))
	pause=$(($pause * $step))
	echo $pause
}

function restorePower {
  echo "Restoring power to USB port..."
  setUsbPower 1
}
trap restorePower EXIT

chargePauseSeconds=20 # Default time to pause charging in seconds 
restorePower
sleep 5
while :; 
  	do 
  	# clear
  	
  	batterylevel=$(getBatteryLevel)

  	echo "----------------------------------------------"
  	echo $(date)
  	echo "Battery level: $batterylevel %"
  	echo "Stop level: $CHARGE_STOP_LEVEL %"

	if [[ $batterylevel -ge $CHARGE_STOP_LEVEL ]]; then
		# msg="battery is at $batterylevel%"
		# echo $msg
        # say $msg

        if [[ $batterylevel -gt $CHARGE_STOP_LEVEL ]]; then
        	echo "Charge is going over, we are pausing too little"
        	chargePauseSeconds=$(backOff $chargePauseSeconds)
        	echo "Increasing pause duration to $chargePauseSeconds seconds"
        fi

        echo "Turning off USB power for $chargePauseSeconds seconds..."
        setUsbPower 0
        sleep $chargePauseSeconds
        echo "Turning USB power back on..."
        setUsbPower 1
	else
		# If battery is below stop level, just keep charging
		if [[ $IS_CHARGING -eq 0 ]]; then
			setUsbPower 1
		fi
	fi

	if [[ $batterylevel -ge 75 ]]; then
		sleep 5
	else
		sleep 30
	fi
done

# echo 1500000 > /sys/class/power_supply/usb/input_current_limit

