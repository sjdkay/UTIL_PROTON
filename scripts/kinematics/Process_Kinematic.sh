#!/bin/bash
# 21/08/20 - Stephen Kay, University of Regina

KINEMATIC=$1

if [[ -z "$1" ]]; then
    echo "I need a kinematic setting to process!"
    echo "Please provide a kinematic setting as input"
    exit 2
fi
declare -i Autosub=0
read -p "Auto submit batch jobs for missing replays/analyses? <Y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
    Autosub=$((Autosub+1))
else echo "Will not submit any batch jobs, please check input lists manually and submit if needed"
fi

echo "######################################################"
echo "### Processing kinematic ${KINEMATIC} ###"
echo "######################################################"

# Set path depending upon hostname. Change or add more as needed  
if [[ "${HOSTNAME}" = *"farm"* ]]; then  
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    if [[ "${HOSTNAME}" != *"ifarm"* ]]; then
	source /site/12gev_phys/softenv.sh 2.3
	source /apps/root/6.18.04/setroot_CUE.bash
    fi
    cd "$REPLAYPATH"
    source "$REPLAYPATH/setup.sh"
elif [[ "${HOSTNAME}" = *"qcd"* ]]; then
    REPLAYPATH="/group/c-pionlt/USERS/${USER}/hallc_replay_lt"
    source /site/12gev_phys/softenv.sh 2.3
    source /apps/root/6.18.04/setroot_CUE.bash
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
declare -i TestingVar=1 # This checks if the replays required are present
if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays"
    else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays"
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
    runNum=$line
    if [[ ! -f "$REPLAYPATH/UTIL_PROTON/ROOTfiles/Scalers/coin_replay_scalers_${runNum}_150000.root" || ! -f "$REPLAYPATH/UTIL_PROTON/ROOTfiles/Analysis/ProtonLT/Proton_coin_replay_production_${runNum}_-1.root" ]]; then
	echo "Scaler or replayfile not found for run $runNum in $REPLAYPATH/UTIL_PROTON/ROOTfiles/"
	echo "${runNum}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays"	
	TestingVar=$((TestingVar+1))
    fi
done < "$RunListFile"

if [ $TestingVar == 1 ]; then
    echo "All replay files and analysed files present - processing"
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays"
elif [ $TestingVar != 1 ]; then
    cp "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays" "$REPLAYPATH/UTIL_BATCH/InputRunLists/${KINEMATIC}_MissingReplays"
    if [ $Autosub == 1 ]; then
	yes y | eval "$REPLAYPATH/UTIL_BATCH/batch_scripts/run_batch_ProtonLT.sh ${KINEMATIC}_MissingReplays"
	exit 4
    else echo "Replays missing, list copied to UTIL_BATCH directory, run if desired"  
  fi
fi
# Check if proton analysis is present for each file in the kinematic, if not, submit a job to process it
TestingVar=$((1)) # Reset the test variable to 1, now check if the analysis is present
if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingProtonAnalysis" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingProtonAnalysis"
else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingProtonAnalysis"
fi
while IFS='' read -r line || [[ -n "$line" ]]; do
    runNum=$line
    RootName+="${runNum}_-1_Analysed_Data.root "
    if [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${runNum}_-1_Analysed_Data.root" ]; then
	echo "Proton analysis not found for run $runNum in ${UTILPATH}/OUTPUT/Analysis/ProtonLT/"
	echo "${runNum}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingProtonAnalysis"
	TestingVar=$((TestingVar+1))
    fi
done < "$RunListFile"

if [ $TestingVar == 1 ]; then
    echo "All proton analysis files found, combining to kinematic"
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingProtonAnalysis"
elif [ $TestingVar != 1 ]; then
    cp "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingProtonAnalysis" "$REPLAYPATH/UTIL_BATCH/InputRunLists/${KINEMATIC}_MissingProtonAnalysis"
    if [ $Autosub == 1 ]; then
	yes y | eval "$REPLAYPATH/UTIL_BATCH/batch_scripts/run_batch_ProtonLT.sh ${KINEMATIC}_MissingProtonAnalysis"
	exit 5
    elif [ $Autosub != 1 ]; then
	echo "Analyses missing, list copied to UTIL_BATCH directory, run on farm if desired"
	read -p "Process python script for missing replays/analyses interactively? <Y/N> " prompt2
	if [[ $prompt2 == "y" || $prompt2 == "Y" || $prompt2 == "yes" || $prompt2 == "Yes" ]]; then
	    cd "${UTILPATH}/scripts/protonyield"
	    while IFS='' read -r line || [[ -n "$line" ]]; do
		runNum=$line
		if [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${runNum}_-1_Analysed_Data.root" ]; then
		    eval '"Analyse_Protons.sh" Proton_coin_replay_production ${runNum} -1'
		fi
	    done < "$RunListFile"
	    else echo "Not processing python script interactively. Analyses missing, list copied to UTIL_BATCH directory, run if desired"
	fi
    fi
fi

if [ $TestingVar == 1 ]; then   
    declare -i TestingVar2=1

    if [[ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingProtonAnalysis" && ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays" ]]; then
	echo "No missing replays or proton analyses detected, processing kinematic"
    elif [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingReplays" ]; then
	echo "Missing proton replays detected for ${KINEMATIC} - check lists and process as needed"
	 TestingVar2=$((TestingVar2+1))
    elif [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_MissingProtonAnalysis" ]; then
	echo "Missing proton analyses detected for ${KINEMATIC} - check lists and process as needed"
	 TestingVar2=$((TestingVar2+1))
    fi

    if [ $TestingVar2 == 1 ]; then 
    	if [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}.root" ]; then
    	    cd "${UTILPATH}/OUTPUT/Analysis/ProtonLT"
    	    KINFILE="${KINEMATIC}.root"
    	    hadd ${KINFILE} ${RootName}
    	    if [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_Protons.root" ]; then
    		root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics.C(\"${KINFILE}\", \"${KINEMATIC}_Protons\")"
    	    elif [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_Protons.pdf" ]; then
    		root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics.C(\"${KINFILE}\", \"${KINEMATIC}_Protons\")"
    	    else echo "Proton plots already found in - ${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_Protons.root and .pdf - Plotting macro skipped"
    	    fi
	    if [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_Protons_NoRF.root" ]; then
    		root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics_NoRFCut.C(\"${KINFILE}\", \"${KINEMATIC}_Protons_NoRF\")"
    	    elif [ ! -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_Protons_NoRF.pdf" ]; then
    		root -b -l -q "${UTILPATH}/scripts/protonyield/PlotProtonPhysics_NoRFCut.C(\"${KINFILE}\", \"${KINEMATIC}_Protons_NoRF\")"
    	    else echo "Proton plots (without RF cut) already found in - ${UTILPATH}/OUTPUT/Analysis/ProtonLT/${KINEMATIC}_Protons_NoRF.root and .pdf - Plotting macro skipped"
    	    fi

    	else echo "${KINEMATIC} already analysed, skipping"
    	fi
    fi
fi

exit 0

