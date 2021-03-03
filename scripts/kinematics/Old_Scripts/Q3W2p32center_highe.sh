#!/bin/bash

# 26/05/20 - Stephen Kay, University of Regina

echo "Starting analysis of Q2 = 3.0, W = 2.32, central angle, high espilon setting"

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
SCRIPTPATH="${REPLAYPATH}/UTIL_PROTON/scripts/protonyield/Analyse_Protons.sh"
RunListFile="${UTILPATH}/scripts/kinematics/Q3W2p32center_highe"
while IFS='' read -r line || [[ -n "$line" ]]; do
    runNum=$line
    RootName+="${runNum}_-1_Analysed_Data.root "
    eval '"$SCRIPTPATH" $runNum -1'
done < "$RunListFile"
sleep 1
cd "${UTILPATH}/scripts/protonyield/OUTPUT"
KINFILE="Q3W2p32center_highe.root"
hadd ${KINFILE} ${RootName}

if [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/Q3W2p32center_highe_Protons.root" ]; then
    root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics.C(\"${KINFILE}\", \"Q3W2p32center_highe_Protons\")"
elif [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/Q3W2p32center_highe_Protons.pdf" ]; then
    root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics.C(\"${KINFILE}\", \"Q3W2p32center_highe_Protons\")"
else echo "Proton plots already found in - ${UTILPATH}/scripts/protonyield/OUTPUT/Q3W2p32center_highe_Protons.root and .pdf - Plotting macro skipped"
fi
exit 0
