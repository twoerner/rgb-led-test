#!/bin/bash
# SPDX-License-Identifier: OSL-3.0
# Copyright (C) 2023  Trevor Woerner <twoerner@gmail.com>

# a bash script to exercise the RGB led on the Nezha-D1
# make sure the following is enabled in the kernel:
#	CONFIG_LEDS_SUN50I_A100

BASEDIR=/sys/class/leds/rgb\:status
CURRENTMODE=$(cat $BASEDIR/trigger | cut -d'[' -f2 | cut -d']' -f1)
CURRENTVALS=$(cat $BASEDIR/multi_intensity)

cleanup() {
	echo $CURRENTMODE > $BASEDIR/trigger
	echo "$CURRENTVALS" > $BASEDIR/multi_intensity
}
trap cleanup EXIT

echo oneshot > $BASEDIR/trigger
echo 32 > $BASEDIR/brightness

declare -A COLORS
declare -A DIRECTIONS
declare -A COLORSTEPS

COLORS[RED]=$(($RANDOM % 255))
COLORS[GRN]=$(($RANDOM % 255))
COLORS[BLU]=$(($RANDOM % 255))
DIRECTIONS[RED]="up"
DIRECTIONS[GRN]="down"
DIRECTIONS[BLU]="down"
COLORSTEPS[RED]=$((($RANDOM % 15)+5))
COLORSTEPS[GRN]=$((($RANDOM % 15)+5))
COLORSTEPS[BLU]=$((($RANDOM % 15)+5))

while [ 1 ]; do
	#echo "RED:${COLORS[RED]} GRN:${COLORS[GRN]} BLU:${COLORS[BLU]} (${DIRECTIONS[RED]},${DIRECTIONS[GRN]},${DIRECTIONS[BLU]}) (${COLORSTEPS[RED]},${COLORSTEPS[GRN]},${COLORSTEPS[BLU]})"
	echo "${COLORS[RED]} ${COLORS[GRN]} ${COLORS[BLU]}" > $BASEDIR/multi_intensity

	# update
	for i in ${!COLORS[*]}; do
		if [ "${DIRECTIONS[$i]}" = "up" ]; then
			COLORS[$i]=$((${COLORS[$i]} + ${COLORSTEPS[$i]}))
		else
			COLORS[$i]=$((${COLORS[$i]} - ${COLORSTEPS[$i]}))
		fi

		if ((${COLORS[$i]} < 0)); then
			COLORS[$i]=$((-${COLORS[$i]}))
			COLORSTEPS[$i]=$((($RANDOM % 15)+5))
			DIRECTIONS[$i]="up"
		fi
		if ((${COLORS[$i]} > 255)); then
			COLORS[$i]=$((${COLORS[$i]} - (2 * ${COLORSTEPS[$i]})))
			COLORSTEPS[$i]=$((($RANDOM % 15)+5))
			DIRECTIONS[$i]="down"
		fi
	done

	sleep .3
done
