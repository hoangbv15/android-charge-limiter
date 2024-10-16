# Android Charge Limiter

This is a bash script that constantly monitors the battery level of any modern Android phone, and intermittently cuts USB power to the phone once the level reaches a configurable threshold.

It does not require an app on the phone to operate. It however utilises https://github.com/mvp/uhubctl, which requires a USB hub capable of power switching. The list of verified working hubs is on the `uhubctl` repo. Some computers have built-in USB ports that support power switching, such as Raspberry Pis.

For retrieving battery levels, it uses `adb` and requires USB Debugging to be enabled on the phone.

## Usage guide
First, make sure `uhubctl` is installed on your computer. Refer to the github repo for installation steps. Also make sure USB debugging is enabled on the phone.

Plug a compatible USB hub to the computer, and plug the phone to the hub. Allow USB debugging for this computer if the popup appears on your phone.

Use the command `uhubctl` to find out the name of the hub and port that the phone is plugged into. This is an example output
```
Current status for hub 0-1.1.3 [0bda:5413 Dell Inc. Dell dock, USB 2.10, 6 ports, ppps]
  Port 1: 0503 power highspeed enable connect [18d1:4ee7 Google Pixel 4a 151XXXXXXX98]
```
Note the hub and port number (hub 0-1.1.3 and port 1).

Open the script and edit the lines containing the `USB_HUB` and `USB_PORT` variables with the values found above.

Allow the script to be executed
```
chmod +x charge_limiter.sh
```

Finally, run the script with 
```
./charge_limiter.sh
```
