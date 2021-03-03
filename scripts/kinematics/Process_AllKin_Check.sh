#!/bin/bash
# 17/09/20 - Stephen Kay, University of Regina

KINEMATIC_LIST=$1
if [[ -z "$1" ]]; then
    echo "I need a kinematic setting list to process!"
    echo "Please provide a kinematic setting list as input"
    exit 2
fi
declare -i Autocleanup=0
read -p "Automatically cleanup failed kinematics?? <Y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
    Autocleanup=$((Autocleanup+1))
else echo "Will cleanup failed kinematic settings, delete manually if desired"
fi
echo "######################################################################"
echo "Checking all kinematic settings provided in list - ${KINEMATIC_LIST}"
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
KINEMATIC_LIST_FILE="${UTILPATH}/scripts/kinematics/${KINEMATIC_LIST}"
if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Completed_Kinematics" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Completed_Kinematics"
    else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Completed_Kinematics"
fi
if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Incomplete_Kinematics" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Incomplete_Kinematics"
else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Incomplete_Kinematics"
fi
if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/PartiallyComplete_Kinematics" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/PartiallyComplete_Kinematics"
else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/PartiallyComplete_Kinematics"
fi

while IFS='' read -r line || [[ -n "$line" ]]; do
    Kinematic=$line
    KinematicAnalysis="${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}.root"
    KinematicPrroot="${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_Protons.root"
    KinematicPrpdf="${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_Protons.pdf"
    KinematicPrNoRFroot="${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_Protons_NoRF.root"
    KinematicPrNoRFpdf="${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_Protons_NoRF.pdf"
    declare -i PartialComplete=0
    
    if [ ! -f "${KinematicAnalysis}" ]; then
    	echo "${Kinematic}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Incomplete_Kinematics"
    elif [ -f "${KinematicAnalysis}" ]; then
	if [[ -f "${KinematicPrroot}" && -f "${KinematicPrpdf}" ]]; then
	    if [[ -f "${KinematicPrNoRFroot}" && -f "${KinematicPrNoRFpdf}" ]]; then
		echo "${Kinematic}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Completed_Kinematics"
	    else
		PartialComplete=$((1))
		echo "${Kinematic}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Incomplete_Kinematics"
	    fi
	else 
	    PartialComplete=$((1))
	    echo "${Kinematic}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Incomplete_Kinematics"
	fi
	if [[ $PartialComplete == 1 ]]; then
	    if [[ $Autocleanup == 1 ]]; then
		rm "${KinematicAnalysis}"
		if [ -f "${KinematicPrroot}" ]; then
		    rm "${KinematicPrroot}"
		fi
		if [ -f "${KinematicPrpdf}" ]; then
		    rm "${KinematicPrpdf}"
		fi
		if [ -f "${KinematicPrNoRFroot}" ]; then
		    rm "${KinematicPrNoRFroot}"
		fi
		if [ -f "${KinematicPrNoRFpdf}" ]; then
		    rm "${KinematicPrNoRFpdf}"
		fi
		echo "${Kinematic} did not fully process, cleaned up automatically"
		echo "${Kinematic}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/PartiallyComplete_Kinematics"
	    elif [[ $Autocleanup == 0 ]]; then
		echo "${Kinematic} did not fully process, NOT cleaned up automatically"
		echo "${Kinematic}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/PartiallyComplete_Kinematics"
	    fi
	fi
    fi
done < "$KINEMATIC_LIST_FILE"
