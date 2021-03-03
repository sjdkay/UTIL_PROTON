#!/bin/bash

# 15/09/20 - Stephen Kay, University of Regina
KINEMATIC_LIST=$1
if [[ -z "$1" ]]; then
    echo "I need a kinematic setting list to process!"
    echo "Please provide a kinematic setting list as input"
    exit 2
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
else REPLAYPATH="/home/sjdkay/Work/JLab"
fi
UTILPATH="${REPLAYPATH}/UTIL_PROTON"
KINEMATIC_LIST_FILE="${UTILPATH}/scripts/protonyield/$KINEMATIC_LIST"

while IFS='' read -r line || [[ -n "$line" ]]; do
    Kinematic=$line
    touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT${Kinematic}_Output"
    root -l -b -q "Fit_MMp_BGSub.C(\"${Kinematic}.root\", \"${Kinematic}_Fit\")" > "${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_Output"
done < "$KINEMATIC_LIST_FILE"

if [ -f "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Fit_Parameters.csv" ]; then
    rm "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Fit_Parameters.csv"
else touch "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Fit_Parameters.csv"
fi

echo "Kinematic,LinBGSl,LinBGSlEr,LinBGIn,LinBGInEr,AmpOm1,AmpOm1Er,MeanOm1,MeanOm1Er,SigOm1,SigOm1Er,AmpOm2,AmpOm2Er,MeanOm2,MeanOm2Er,SigOm2,SigOm2Er,AmpPhi,AmpPhiEr,MeanPhi,MeanPhiEr,SigPhi,SigPhiEr" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Fit_Parameters.csv"
while IFS='' read -r line || [[ -n "$line" ]]; do
    Kinematic=$line
    KinematicOutputFile="${UTILPATH}/OUTPUT/Analysis/ProtonLT/${Kinematic}_Output"
    # awk command to print 3rd tabbed variable of line 7 from file, NR == LINE, print TABBED VALUE
    LinBGSl=$(awk 'NR==7{print $3}' ${KinematicOutputFile}) 
    LinBGSlEr=$(awk 'NR==7{print $4}' ${KinematicOutputFile})
    LinBGIn=$(awk 'NR==8{print $3}' ${KinematicOutputFile})
    LinBGInEr=$(awk 'NR==8{print $4}' ${KinematicOutputFile})
    AmpOm1=$(awk 'NR==13{print $3}' ${KinematicOutputFile})
    AmpOm1Er=$(awk 'NR==13{print $4}' ${KinematicOutputFile})
    MeanOm1=$(awk 'NR==14{print $3}' ${KinematicOutputFile})
    MeanOm1Er=$(awk 'NR==14{print $4}' ${KinematicOutputFile})
    SigOm1=$(awk 'NR==15{print $3}' ${KinematicOutputFile})
    SigOm1Er=$(awk 'NR==15{print $4}' ${KinematicOutputFile})
    AmpOm2=$(awk 'NR==22{print $3}' ${KinematicOutputFile})
    AmpOm2Er=$(awk 'NR==22{print $4}' ${KinematicOutputFile})
    MeanOm2=$(awk 'NR==23{print $3}' ${KinematicOutputFile})
    MeanOm2Er=$(awk 'NR==23{print $4}' ${KinematicOutputFile})
    SigOm2=$(awk 'NR==24{print $3}' ${KinematicOutputFile})
    SigOm2Er=$(awk 'NR==24{print $4}' ${KinematicOutputFile})
    AmpPhi=$(awk 'NR==25{print $3}' ${KinematicOutputFile})
    AmpPhiEr=$(awk 'NR==25{print $4}' ${KinematicOutputFile})
    MeanPhi=$(awk 'NR==26{print $3}' ${KinematicOutputFile})
    MeanPhiEr=$(awk 'NR==26{print $4}' ${KinematicOutputFile})
    SigPhi=$(awk 'NR==27{print $3}' ${KinematicOutputFile})
    SigPhiEr=$(awk 'NR==27{print $4}' ${KinematicOutputFile})
    echo "${Kinematic},${LinBGSl},${LinBGSlEr},${LinBGIn},${LinBGInEr},${AmpOm1},${AmpOm1Er},${MeanOm1},${MeanOm1Er},${SigOm1},${SigOm1Er},${AmpOm2},${AmpOm2Er},${MeanOm2},${MeanOm2Er},${SigOm2},${SigOm2Er},${AmpPhi},${AmpPhiEr},${MeanPhi},${MeanPhiEr},${SigPhi},${SigPhiEr}" >> "${UTILPATH}/OUTPUT/Analysis/ProtonLT/Fit_Parameters.csv"

done < "$KINEMATIC_LIST_FILE"

