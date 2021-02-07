#!/bin/bash

############################################################################################
#
#  A PULSE AUDIO SCRIPT TO CONTROL THE ACTIVE SINK'S VOLUME
#
#    The script can set the volume to a value, raise or lower the volume by an amount (all these in
#    percentages), mute, unmute and toggle.
#
############################################################################################

# Usage:
#	pavolume.sh [-|+]VOL | mute | unmute | toggle
#
# Ex.:	pavolume.sh 100
#	pavolume.sh -5
#	pavolume.sh +5
#	pavolume.sh mute
#	pavolume.sh unmute
#	pavolume.sh toggle   # mute/unmute


# Get pulse audio active sink
sink=$(pacmd list-sinks | grep \* | awk '{print $3}')

if [[ $1 == 'mute' ]]; then	
	pactl set-sink-mute $sink 1
elif [[ $1 = 'unmute' ]]; then
	pactl set-sink-mute $sink 0
elif [[ $1 == 'toggle' ]]; then
	pactl set-sink-mute $sink toggle
else
	# Change active sink volume
	pactl set-sink-volume $sink $1%

	# Check the volume
	new_vol=$(pacmd list-sinks | grep '^[[:space:]]volume:' | head -n $(( $sink + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
	# If the volume is above 100%
	if [ $new_vol -gt 100 ]; then
		# Set it to 100%
		pactl set-sink-volume $sink 100%
	fi
fi
