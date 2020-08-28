#!/bin/bash

# 14/08/20 - Stephen Kay, University of Regina
KINEMATIC_LIST=$1
if [[ -z "$1" ]]; then
    echo "I need a kinematic setting list to process!"
    echo "Please provide a kinematic setting list as input"
    exit 2
fi

echo "#################################"
echo "Processing all kinematic settings"
echo "#################################"

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	source /site/12gev_phys/softenv.sh 2.3
    fi
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
    source /site/12gev_phys/softenv.sh 2.3
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh" 
elif [[ "${HOSTNAME}" = *"cdaq"* ]]; then
    REPLAYPATH="/home/cdaq/hallc-online/hallc_replay_lt"
elif [[ "${HOSTNAME}" = *"phys.uregina.ca"* ]]; then
    REPLAYPATH="/home/${USER}/work/JLab/hallc_replay_lt"
fi
UTILPATH="${REPLAYPATH}/UTIL_PROTON"
KINEMATIC_LIST_FILE="${UTILPATH}/scripts/kinematics/$KINEMATIC_LIST"
while IFS='' read -r line || [[ -n "$line" ]]; do
    Kinematic=$line
    eval "${UTILPATH}/scripts/kinematics/Process_Kinematic.sh ${Kinematic}"
    sleep 15
done < "$KINEMATIC_LIST_FILE"

