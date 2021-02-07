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

# Save argument to variable
opt=$1

# Set constant for max volume
MAX=100
# Get pulse audio active sink
sink=$(pacmd list-sinks | grep \* | awk '{print $3}')

if [[ $opt == 'mute' ]]; then	
	pactl set-sink-mute $sink 1
elif [[ $opt = 'unmute' ]]; then
	pactl set-sink-mute $sink 0
elif [[ $opt == 'toggle' ]]; then
	pactl set-sink-mute $sink toggle
else
	# Change active sink volume
	pactl set-sink-volume $sink $opt%

	# Check the volume
	new_vol=$(pacmd list-sinks | grep '^[[:space:]]volume:' | head -n $(( $sink + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
	# If the volume is above max%
	if [ $new_vol -gt $MAX ]; then
		# Set it to the max
		pactl set-sink-volume $sink $MAX%
	fi

	# Unmute sink in case it was muted
	pactl set-sink-mute $sink 0
fi
