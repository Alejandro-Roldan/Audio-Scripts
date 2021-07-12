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
	if [[ $opt == +* ]]; then
		# Remove the starting "+" to get only the number
		opt_num=${opt:1}
		# Get the current volume
		# head -n $(( $sink +1 )) was used in raspberry, but here that doesn't work and needs to be just $sink
		vol=$(pacmd list-sinks | grep '^[[:space:]]volume:' | head -n $sink | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
		# Get what would be the new volume
		new_vol=$(( vol+opt_num ))
		# If the new volume is above max%
		if [ $new_vol -gt $MAX ]; then opt=$MAX; fi
	fi

	# Change active sink volume
	pactl set-sink-volume $sink $opt%

	# Unmute sink in case it was muted
	pactl set-sink-mute $sink 0
fi
