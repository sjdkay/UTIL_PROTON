#!/bin/bash

# 14/08/20 - Stephen Kay, University of Regina
KINEMATIC_LIST=$1
if [[ -z "$1" ]]; then
    echo "I need a kinematic setting list to process!"
    echo "Please provide a kinematic setting list as input"
    exit 2
fi
declare -i Autosub=0
read -p "Auto submit batch jobs for missing replays/analyses? <Y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
    Autosub=$((Autosub+1))
else echo "Will not submit any batch jobs, please check input lists manually and submit if needed"
fi
echo "######################################################################"
echo "Processing all kinematic settings provided in list - ${KINEMATIC_LIST}"
echo "######################################################################"

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	source /site/12gev_phys/softenv.sh 2.3
    fi
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
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
if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/MissingReplays" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/MissingReplays"
    else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/MissingReplays"
fi
if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/BrokenProtonAnalysis" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/BrokenProtonAnalysis"
else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/BrokenProtonAnalysis"
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
    Kinematic=$line
    if [ $Autosub == 1 ]; then
	yes y | eval "${UTILPATH}/scripts/kinematics/Process_Kinematic.sh ${Kinematic}"
    else yes N | eval "${UTILPATH}/scripts/kinematics/Process_Kinematic.sh ${Kinematic}"
    fi
    echo "${Kinematic}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/MissingReplays"
    echo "${Kinematic}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/BrokenProtonAnalysis"
    if [[ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_MissingProtonAnalysis" ]]; then
     	cat "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_MissingProtonAnalysis" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/MissingReplays"  
     	rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_MissingProtonAnalysis"
    fi
    if [[ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_BrokenProtonAnalysis" ]]; then
     	cat "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_BrokenProtonAnalysis" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/BrokenProtonAnalysis"
     	rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_BrokenProtonAnalysis"
    fi
    sleep 5
done < "$KINEMATIC_LIST_FILE"
