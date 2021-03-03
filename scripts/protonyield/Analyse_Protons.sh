#!/bin/bash

# 16/06/20 - Stephen Kay, University of Regina
# Executes the python analysis script (if needed) and the root plotting script for a given run number
# Configfilename should be the file based in UTIL_PROTON/CONFIG (Not the full path, just the actual filename)

echo "Starting analysis of Proton events"
echo "I take as arguments the run prefix, run number and max number of events!"
RUNPREFIX=$1
if [[ -z "$1" ]]; then
    echo "I need a Run Prefix!"
    echo "Please provide a run prefix as input"
    exit 2
fi
RUNNUMBER=$2
if [[ -z "$2" ]]; then
    echo "I need a Run Number!"
    echo "Please provide a run number as input"
    exit 2
fi
MAXEVENTS=$3
if [[ -z "$3" ]]; then
    echo "Only Run Number entered...I'll assume -1 (all) events!" 
    MAXEVENTS=-1 
fi

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh" 
elif [[ "${HOSTNAME}" = *"cdaq"* ]]; then
    REPLAYPATH="/home/cdaq/hallc-online/hallc_replay_lt"
elif [[ "${HOSTNAME}" = *"phys.uregina.ca"* ]]; then
    REPLAYPATH="/home/${USER}/work/JLab/hallc_replay_lt"
fi
UTILPATH="${REPLAYPATH}/UTIL_PROTON"
cd "${UTILPATH}/scripts"

if [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${RUNNUMBER}_${MAXEVENTS}_Analysed_Data.root" ]; then
    python3 ${UTILPATH}/scripts/protonyield/src/Protonyield.py ${RUNPREFIX} ${RUNNUMBER} ${MAXEVENTS}
else echo "Analysed root file already found in ${UTILPATH}/OUTPUT/Analysis/ProtonLT/ - Skipped python script step"
fi

if [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Proton_Histos_${RUNNUMBER}_${MAXEVENTS}.root" ]; then
    root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics.C(\"${RUNNUMBER}_${MAXEVENTS}_Analysed_Data.root\", \"Proton_Histos_${RUNNUMBER}_${MAXEVENTS}\")"
elif [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Proton_Histos_${RUNNUMBER}_${MAXEVENTS}.pdf" ]; then
    root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics.C(\"${RUNNUMBER}_${MAXEVENTS}_Analysed_Data.root\", \"Proton_Histos_${RUNNUMBER}_${MAXEVENTS}\")"
else echo "Proton plots already found in - ${UTILPATH}/OUTPUT/Analysis/ProtonLT/Proton_Histos_${RUNNUMBER}_${MAXEVENTS}.root and .pdf - Plotting macro skipped"
fi
exit 0



