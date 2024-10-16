USB_HUB=0-1.1.3
USB_PORT=1
CHARGE_STOP_LEVEL=80

IS_CHARGING=1

# adb root
function setUsbPower {
	IS_CHARGING=$1
	# uhubctl -l 0-1.1.3 -a 0 -p 1
	timeout 5 uhubctl -l $USB_HUB -a $1 -p $USB_PORT #> /dev/null
}

function getBatteryLevel {
	# The below is equivalent to
	# adb shell dumpsys battery get level
	# On some old phones, the adb server does not have the get command
	adb shell dumpsys battery | grep level | tr -d -c 0-9
}

function backOff {
	local pause=$1
	local step=$2
	local stepOver=$(echo "3^$step" | bc)
	local stepUnder=$(echo "2^$step" | bc)
	echo $(($pause * $stepOver/$stepUnder))
}

function restorePower {
  echo "Restoring power to USB port..."
  setUsbPower 1
}
trap restorePower EXIT

chargePauseSeconds=30 # Default time to pause charging in seconds 
restorePower
sleep 5
while :; 
  	do 
  	clear
  	
  	batterylevel=$(getBatteryLevel)

  	echo "----------------------------------------------"
  	echo $(date)
  	echo "Battery level: $batterylevel %"
  	echo "Stop level: $CHARGE_STOP_LEVEL %"

	if [[ $batterylevel -ge $CHARGE_STOP_LEVEL ]]; then
		# msg="battery is at $batterylevel%"
		# echo $msg
        # say $msg

        setUsbPower 0
		pause=$chargePauseSeconds
		if [[ $batterylevel -gt $CHARGE_STOP_LEVEL ]]; then
			amountOver=$(($batterylevel - $CHARGE_STOP_LEVEL))
			echo "Charge is going over $amountOver %, increasing pause amount"
        	pause=$(backOff $pause $amountOver)
		fi
        echo "Sleep for $pause seconds..."
		sleep $pause
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

