#!/bin/bash
# 21/08/20 - Stephen Kay, University of Regina

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
    REPLAYPATH="/group/c-kaonlt/USERS/${USER}/hallc_replay_lt"
    source /site/12gev_phys/softenv.sh 2.3
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
SCRIPTPATH="${REPLAYPATH}/UTIL_PROTON/scripts/protonyield/Analyse_Protons.sh"
RunListFile="${UTILPATH}/scripts/kinematics/${KINEMATIC}"
if [ ! -f "${RunListFile}" ]; then
    echo "Error, ${RunListFile} not found, exiting"
    exit 3
fi
cd $REPLAYPATH
declare -i TestingVar=1
if [ -f "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingReplays" ]; then
    rm "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingReplays"
    else touch "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingReplays"
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
    runNum=$line
    if [[ ! -f "$REPLAYPATH/UTIL_PROTON/ROOTfilesProton/coin_replay_scalers_${runNum}_150000.root" || ! -f "$REPLAYPATH/UTIL_PROTON/ROOTfilesProton/Proton_coin_replay_production_${runNum}_-1.root" ]]; then
	echo "Scaler or replayfile not found for run $runNum in $REPLAYPATH/UTIL_PROTON/ROOTfilesProton/"
	echo "${runNum}" >> "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingReplays"	
	TestingVar=$((TestingVar+1))
    fi
done < "$RunListFile"

if [ $TestingVar == 1 ]; then
    echo "All replay files and analysed files present - processing"
elif [ $TestingVar != 1 ]; then
    cp "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingReplays" "$REPLAYPATH/UTIL_BATCH/InputRunLists/${KINEMATIC}_MissingReplays"
    yes y | eval "$REPLAYPATH/UTIL_BATCH/batch_scripts/run_batch_NewProtonLT.sh ${KINEMATIC}_MissingReplays"
fi

if [ $TestingVar == 1 ]; then   
    source /apps/root/6.18.04/setroot_CUE.bash
    declare -i TestingVar2=1

    if [ -f "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingProtonAnalysis" ]; then
	rm "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingProtonAnalysis"
    else touch "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingProtonAnalysis"
    fi

    while IFS='' read -r line || [[ -n "$line" ]]; do
	runNum=$line
	RootName+="${runNum}_-1_Analysed_Data.root "
	if [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/${runNum}_-1_Analysed_Data.root" ]; then
	    echo "Proton analysis not found for run $runNum in ${UTILPATH}/scripts/protonyield/OUTPUT/"
	    echo "Processing proton analysis for run $runNum"
	    echo "${runNum}" >> "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_MissingProtonAnalysis"	
	    eval '"$SCRIPTPATH" $runNum -1'
	    sleep 1
	fi
    done < "$RunListFile"

    if [ -f "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_BrokenProtonAnalysis" ]; then
	rm "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_BrokenProtonAnalysis"
    else touch "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_BrokenProtonAnalysis"
    fi

    while IFS='' read -r line || [[ -n "$line" ]]; do
	runNum=$line
	if [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/${runNum}_-1_Analysed_Data.root" ]; then
	    TestingVar2=$((TestingVar2+1))
	    echo " !!! WARNING !!! Proton analysis files *STILL* not found !!!"
	    echo "${runNum}" >> "${UTILPATH}/scripts/kinematics/OUTPUT/${KINEMATIC}_BrokenProtonAnalysis"	
	fi
    done < "$RunListFile"

    if [ $TestingVar2 == 1 ]; then 
	if [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/${KINEMATIC}.root" ]; then
	    cd "${UTILPATH}/scripts/protonyield/OUTPUT"
	    KINFILE="${KINEMATIC}.root"
	    hadd ${KINFILE} ${RootName}
	    if [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/${KINEMATIC}_Protons.root" ]; then
		root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics.C(\"${KINFILE}\", \"${KINEMATIC}_Protons\")"
	    elif [ ! -f "${UTILPATH}/scripts/protonyield/OUTPUT/${KINEMATIC}_Protons.pdf" ]; then
		root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics.C(\"${KINFILE}\", \"${KINEMATIC}_Protons\")"
	    else echo "Proton plots already found in - ${UTILPATH}/scripts/protonyield/OUTPUT/${KINEMATIC}_Protons.root and .pdf - Plotting macro skipped"
	    fi
	else echo "${KINEMATIC} already analysed, skipping"
	fi
    fi
fi

exit 0

