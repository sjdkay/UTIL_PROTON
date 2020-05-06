#!/bin/bash

# 06/05/20 - Stephen Kay, University of Regina
# Executes the python analysis script (if needed) and the root plotting script for a given run number
# Configfilename should be the file based in UTIL_PROTON/CONFIG (Not the full path, just the actual filename)

echo "Starting analysis of Kaon events"
echo "I take as arguments the run Number, max number of events and configfile name!"
RUNNUMBER=$1
MAXEVENTS=$2
CONFIGFILE=$3
if [[ -z "$1" ]]; then
    echo "I need a Run Number!"
    echo "Please provide a run number as input"
    exit 2
fi
if [[ -z "$2" ]]; then
    echo "Only Run Number entered...I'll assume -1 events!" 
    MAXEVENTS=-1 
fi
if [[ -z "$3" ]]; then
    echo "I need a config file name!"
    echo "Please provide a config file name as a 3rd input!"
    exit 3 
fi

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
cd "${UTILPATH}/scripts"

if [ ! -f "${UTILPATH}/config/${CONFIGFILE}" ]; then
    echo "Error, ${CONFIGFILE} not found in path ${UTILPATH}/config/${CONFIGFILE}"
    echo "Check the path and retry"
    exit 4
fi

if [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/${RUNNUMBER}_${MAXEVENTS}_Analysed_Data.root" ]; then
    python3 ${UTILPATH}/scripts/protonyield/src/ProtonYield.py ${RUNNUMBER} ${MAXEVENTS} ${CONFIGFILE}
else echo "Analysed root file already found in ${UTILPATH}/scripts/protonyield/OUTPUT/ - Skipped python script step"
fi

if [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/Kaon_Histos_${RUNNUMBER}_${MAXEVENTS}.root" ]; then
    root -b -l -q "${UTILPATH}/scripts/protonyield/PlotKaonPhysics.C(\"${RUNNUMBER}_${MAXEVENTS}_Analysed_Data.root\", \"Kaon_Histos_${RUNNUMBER}_${MAXEVENTS}\")"
elif [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/Kaon_Histos_${RUNNUMBER}_${MAXEVENTS}.pdf" ]; then
    root -b -l -q "${UTILPATH}/scripts/protonyield/PlotKaonPhysics.C(\"${RUNNUMBER}_${MAXEVENTS}_Analysed_Data.root\", \"Kaon_Histos_${RUNNUMBER}_${MAXEVENTS}\")"
else echo "Kaon plots already found in - ${UTILPATH}/scripts/protonyield/OUTPUT/Kaon_Histos_${RUNNUMBER}_${MAXEVENTS}.root and .pdf - Plotting macro skipped"
fi
exit 0



