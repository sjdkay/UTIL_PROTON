#! /usr/bin/python

# 20/4/20 - Stephen Kay, University of Regina

# Python version of the proton analysis script. Now utilises uproot to select event of each type and writes them to a root file
# Intention is to apply PID/selection cutting here and plot in a separate script
# Python should allow for easier reading of databases storing timing offsets e.t.c.

# Import relevant packages
import uproot as up
import numpy as np
import pandas as pd
import ROOT
import scipy
import scipy.integrate as integrate
import matplotlib.pyplot as plt
import sys, math, os, subprocess

sys.path.insert(0, 'python/')

# Input params - run number and max number of events
runNum = sys.argv[1]
MaxEvent=sys.argv[2]

USER = subprocess.getstatusoutput("whoami") # Grab user info for file finding

rootName = "/u/group/c-kaonlt/USERS/%s/hallc_replay_lt/UTIL_PROTON/ROOTfilesProton/Proton_coin_replay_production_%s_%s.root" % (USER[1], runNum,MaxEvent)

# Read stuff from the main event tree
e_tree = up.open(rootName)["T"]

# Timing info
CTime_ePiCoinTime_ROC1 = e_tree.array("CTime.ePiCoinTime_ROC1")
CTime_eKCoinTime_ROC1 = e_tree.array("CTime.eKCoinTime_ROC1")
CTime_epCoinTime_ROC1 = e_tree.array("CTime.epCoinTime_ROC1")
P_RF_tdcTime = e_tree.array("T.coin.pRF_tdcTime")
P_hod_fpHitsTime = e_tree.array("P.hod.fpHitsTime")
# HMS info
H_gtr_beta = e_tree.array("H.gtr.beta")
H_gtr_th = e_tree.array("H.gtr.th")
H_gtr_ph = e_tree.array("H.gtr.ph")
H_gtr_dp = e_tree.array("H.gtr.dp")
H_cal_etotnorm = e_tree.array("H.cal.etotnorm")
H_cer_npesum = e_tree.array("H.cer.npeSum")
# SHMS info
P_gtr_beta = e_tree.array("P.gtr.beta")
P_gtr_th = e_tree.array("P.gtr.th")
P_gtr_ph = e_tree.array("P.gtr.ph")
P_gtr_p = e_tree.array("P.gtr.p")
P_gtr_dp = e_tree.array("P.gtr.dp")
P_cal_etotnorm = e_tree.array("P.cal.etotnorm")
P_aero_npeSum = e_tree.array("P.aero.npeSum")
P_hgcer_npeSum = e_tree.array("P.hgcer.npeSum")
P_hgcer_xAtCer = e_tree.array("P.hgcer.xAtCer")
P_hgcer_yAtCer = e_tree.array("P.hgcer.yAtCer")
# Kinematic quantitites
Q2 = e_tree.array("H.kin.primary.Q2")
W = e_tree.array("H.kin.primary.W")
epsilon = e_tree.array("H.kin.primary.epsilon")
ph_q = e_tree.array("P.kin.secondary.ph_xq")
emiss = e_tree.array("P.kin.secondary.emiss")
pmiss = e_tree.array("P.kin.secondary.pmiss")
MandelT = e_tree.array("P.kin.secondary.MandelT")
MandelU = e_tree.array("P.kin.secondary.MandelU")
# Misc quantities
fEvtType = e_tree.array("fEvtHdr.fEvtType")
RFFreq = e_tree.array("MOFC1FREQ")
RFFreqDiff = e_tree.array("MOFC1DELTA")
pEDTM = e_tree.array("T.coin.pEDTM_tdcTime")
# Relevant branches now stored as NP arrays

# Define particle masses for missing mass calculation
Mp = 0.93828
MPi = 0.13957018 
MK = 0.493677
# Calculate missing mass under different particle assumptions
# NOTE, this should be modified for NON different particle assumptions in hcana, this assumes a "kaon" is specified in the kinematics file
MMpi = np.array([math.sqrt(abs((em + math.sqrt(abs((MK*MK) + (gtrp*gtrp))) - math.sqrt(abs((MPi*MPi) + (gtrp*gtrp) - (pm*pm))) ))**2) for (em, pm, gtrp) in zip(emiss, pmiss, P_gtr_p)]) 
MMK = np.array([math.sqrt(abs((em*em)-(pm*pm))) for (em, pm) in zip(emiss, pmiss)])
MMp = np.array([math.sqrt(abs((em + math.sqrt(abs((MK*MK) + (gtrp*gtrp))) - math.sqrt(abs((Mp*Mp) + (gtrp*gtrp) - (pm*pm))) ))**2) for (em, pm, gtrp) in zip(emiss, pmiss, P_gtr_p)])

def hms_elec():
    # Define the array of arrays containing the relevant HMS info
    NoCut_HMS_Elec = [H_gtr_beta, H_gtr_th, H_gtr_ph, H_gtr_dp, H_cal_etotnorm, H_cer_npesum]
    # Create array of arrays of variables after cuts
    Cut_HMS_Elec = [(HBeta, HTh, HPh, Hdel, HCal, HCer)
                    for (HBeta, HTh, HPh, Hdel, HCal, HCer) in zip(*NoCut_HMS_Elec)
                    if abs(Hdel) < 8
                    if abs(HTh) < 0.08
                    if abs(HPh) < 0.045
                    if HCal > 0.7 and HCal <1.5]

    HMS_Electrons = {
        "Uncut_Events" : NoCut_HMS_Elec,
        "Cut_Events" : Cut_HMS_Elec,
    }

    return HMS_Electrons

def shms_pions(): 
    # Define the array of arrays containing the relevant SHMS info
    NoCut_SHMS_Pions = [H_gtr_beta, H_gtr_th, H_gtr_ph, H_gtr_dp, H_cal_etotnorm, H_cer_npesum, CTime_ePiCoinTime_ROC1, P_RF_tdcTime, P_hod_fpHitsTime, P_gtr_beta, P_gtr_th, P_gtr_ph, P_gtr_p, P_gtr_dp, P_cal_etotnorm, P_aero_npeSum, P_hgcer_npeSum, P_hgcer_xAtCer, P_hgcer_yAtCer, MMpi, MMK, MMp]
    # Create array of arrays of pions after cuts, all events, prompt and random
    Cut_SHMS_Pions_all = [(HBeta, HTh, HPh, Hdel, HCal, HCer, CTPi, RF, HodStart, PiBeta, PiTh, PiPh, PiP, PiDel, PiCal, PiAero, PiHGC, PiHGCX, PiHGCY, mm1, mm2, mm3) for (HBeta, HTh, HPh, Hdel, HCal, HCer, CTPi, RF, HodStart, PiBeta, PiTh, PiPh, PiP, PiDel, PiCal, PiAero, PiHGC, PiHGCX, PiHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Pions)
                    if abs(Hdel) < 8
                    if abs(HTh) < 0.08
                    if abs(HPh) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if PiDel > -10 and PiDel < 20
                    if abs(PiTh) < 0.06
                    if abs(PiPh) < 0.04
                    if abs(PiBeta -1.0) < 0.3
                    if PiAero > 1.5
                    if PiHGC > 1.5]
                    # need to add RF timing cut, need to implement database idea
    # Create array of arrays of pions after cuts, prompt events
    # Create array of arrays of pions after cuts, random events
    SHMS_Pions = {
        "Uncut_Events" : NoCut_SHMS_Pions,
        "Cut_Events_All" : Cut_SHMS_Pions_all,
    }

    return SHMS_Pions

def main():
    HMS_Elec_Data = hms_elec()
    SHMS_Pion_Data = shms_pions()
if __name__ == '__main__':
    main()    
