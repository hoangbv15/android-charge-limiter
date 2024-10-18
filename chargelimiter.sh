function readOrCreateConfig {
	if ! [[ -f "$1" ]]; then
		echo "$1 file does not exist, creating with default values"
		echo 'USB_HUB=1-1
USB_PORT=1
CHARGE_STOP_LEVEL=80' > $1
	fi
	source $1
}
readOrCreateConfig ~/chargelimiter.cfg

IS_VERBOSE=0
if [[ $@ == *" -v"* ]]; then
  IS_VERBOSE=1
fi

IS_CHARGING=1

function setUsbPower {
	IS_CHARGING=$1
	# uhubctl -l 0-1.1.3 -a 0 -p 1
	if [[ $IS_VERBOSE == 1 ]]; then
		timeout 5 uhubctl -l $USB_HUB -a $1 -p $USB_PORT
	else
		timeout 5 uhubctl -l $USB_HUB -a $1 -p $USB_PORT > /dev/null
	fi
}

function getBatteryLevel {
	# The below is equivalent to
	# adb shell dumpsys battery get level
	# On some old phones, the adb server does not have the get command
	adb shell dumpsys battery | grep level | tr -d -c 0-9
}

function restorePower {
  echo "Restoring power to USB port..."
  setUsbPower 1
}
trap restorePower EXIT

CHARGE_PAUSE_SECONDS=60 # Default time to pause charging in seconds 
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
		echo "Battery is greaater or equal than stop level, stop charging"
        setUsbPower 0
        echo "Sleep for $CHARGE_PAUSE_SECONDS seconds..."
		sleep $CHARGE_PAUSE_SECONDS
        echo "Turning USB power back on briefly to check battery level..."
        setUsbPower 1
	else
		echo "Battery is below stop level, continue charging..."
		if [[ $IS_CHARGING -eq 0 ]]; then
			setUsbPower 1
		fi
	fi

	if [[ $batterylevel -ge $(($CHARGE_STOP_LEVEL - 5)) ]]; then
		# Wait some seconds for adb to connect to the device
		sleep 5
	else
		# We are more than 5% lower than stop level, no need to 
		# monitor closely
		sleep 30
	fi
done

# echo 1500000 > /sys/class/power_supply/usb/input_current_limit

