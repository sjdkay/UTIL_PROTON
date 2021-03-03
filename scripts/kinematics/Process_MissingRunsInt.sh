#!/bin/bash
# 21/08/20 - Stephen Kay, University of Regina

# Process runs provided in list interactively
KINEMATIC=$1

if [[ -z "$1" ]]; then
    echo "I need a kinematic setting to process!"
    echo "Please provide a kinematic setting as input"
    exit 2
fi

echo "######################################################"
echo "### Processing kinematic ${KINEMATIC} ###"
echo "######################################################"

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    source /site/12gev_phys/softenv.sh 2.3
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
SCRIPTPATH="${REPLAYPATH}/UTIL_PROTON/scripts/protonyield/Analyse_Protons.sh"
RunListFile="${UTILPATH}/scripts/kinematics/${KINEMATIC}"
if [ ! -f "${RunListFile}" ]; then
    echo "Error, ${RunListFile} not found, exiting"
    exit 3
fi
cd $REPLAYPATH
declare -i TestingVar=1
if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays"
    else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays"
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
    runNum=$line
    if [[ ! -f "$REPLAYPATH/UTIL_PROTON/ROOTfiles/Scalerscoin_replay_scalers_${runNum}_150000.root" || ! -f "$REPLAYPATH/UTIL_PROTON/ROOTfiles/Analysis/ProtonLT/Proton_coin_replay_production_${runNum}_-1.root" ]]; then
	echo "Scaler or replayfile not found for run $runNum in $REPLAYPATH/UTIL_PROTON/ROOTfiles/"
	TestingVar=$((TestingVar+1))
    fi
done < "$RunListFile"
cd "$UTILPATH/scripts/protonyield"
if [ $TestingVar == 1 ]; then
    echo "All replay files and analysed files present - processing"
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays"
    source /apps/root/6.18.04/setroot_CUE.bash
    while IFS='' read -r line || [[ -n "$line" ]]; do
	runNum=$line
	eval '"Analyse_Protons.sh" ${runNum} -1'
    done < "$RunListFile"
elif [ $TestingVar != 1 ]; then
    echo "!!! ERROR !!! - Some ROOTfiles missing - see ${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays - !!! ERROR !!!"
fi

exit 0

