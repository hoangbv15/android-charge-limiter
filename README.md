# Android Charge Limiter

This is a bash script for Linux and macOS that constantly monitors the battery level of any modern Android phone, and intermittently cuts USB power to the phone once the level reaches a configurable threshold.

It does not require an app on the phone to operate. It however utilises [uhubctl](https://github.com/mvp/uhubctl), which requires a USB hub capable of power switching. The list of verified working hubs is on the `uhubctl` repo. Some computers have built-in USB ports that support power switching, such as Raspberry Pis.

For retrieving battery levels, it uses `adb` and requires USB Debugging to be enabled on the phone.

## Usage guide
First, make sure 
- `uhubctl` is installed on your computer. Refer to the [github repo](https://github.com/mvp/uhubctl) for installation steps.
- Download the [Android platform tools](https://developer.android.com/tools/releases/platform-tools) and make them available in your path.
- Also make sure USB debugging is enabled on the phone.

Plug a compatible USB hub to the computer, and plug the phone to the hub. Allow USB debugging for this computer if the popup appears on your phone.

Use the command `uhubctl` to find out the name of the hub and port that the phone is plugged into. This is an example output
```
Current status for hub 0-1.1.3 [0bda:5413 Dell Inc. Dell dock, USB 2.10, 6 ports, ppps]
  Port 1: 0503 power highspeed enable connect [18d1:4ee7 Google Pixel 4a 151XXXXXXX98]
```
Note the hub and port number (hub 0-1.1.3 and port 1).

Download this script to your computer using whatever method you prefer, git clone  or copy paste. Open the script and edit the lines containing the `USB_HUB` and `USB_PORT` variables with the values found above.

Allow the script to be executed
```
chmod +x charge_limiter.sh
```

Finally, run the script with 
```
./charge_limiter.sh
```

## Troubleshoot
- Q. Power is still sent to my phone even though the script says it's turning off USB power?

  A. If you have a big and expensive hub such as a DELL thunderbolt dock, it could have bugs in its firmware that prevents `uhubctl` from controlling it properly. Usually a complete power cycle of the dock will solve the problem. If not, try manually setting the power status with the `uhubctl` command. If that still doesn't work, try another port. If it still does not work after all of that, then it's either an issue with `uhubctl` or the hub is not supported.
