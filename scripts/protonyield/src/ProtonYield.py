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
HOST = subprocess.getstatusoutput("hostname")
if ("farm" in HOST[1]):
    REPLAYPATH = "/group/c-kaonlt/USERS/%s/hallc_replay_lt" % USER[1]
elif ("lark.phys.uregina" in HOST[1]):
    REPLAYPATH = "/home/%s/work/JLab/hallc_replay_lt" % USER[1]
# Add more path setting as needed in a similar manner
print("Running as %s on %s, hallc_replay_lt path assumed as %s" % (USER[1], HOST[1], REPLAYPATH))

rootName = "%s/UTIL_PROTON/ROOTfilesProton/Proton_coin_replay_production_%s_%s.root" % (REPLAYPATH, runNum, MaxEvent)
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
H_gtr_xp = e_tree.array("H.gtr.th")
H_gtr_yp = e_tree.array("H.gtr.ph")
H_gtr_dp = e_tree.array("H.gtr.dp")
H_cal_etotnorm = e_tree.array("H.cal.etotnorm")
H_cer_npesum = e_tree.array("H.cer.npeSum")
# SHMS info
P_gtr_beta = e_tree.array("P.gtr.beta")
P_gtr_xp = e_tree.array("P.gtr.th")
P_gtr_yp = e_tree.array("P.gtr.ph")
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

# Info for prompt/random cuts, currently hard coded but need to read in from database in future
PromptPeak = [43.84, 43.75, 44] # Need to read from DB
nWindows = 6 # Number of random windows
BunchSpacing = 4 # Bunch spacing in ns, should also be read from DB
RandomWindows = np.zeros((2, 2, 3)) # Low/high, 1st/2nd value, particle
for x in range (0,3):
    RandomWindows[0][0][x] = PromptPeak[x]-(BunchSpacing/2)-0.25-((nWindows)*BunchSpacing) #Random Low 1
    RandomWindows[0][1][x] = PromptPeak[x]-(BunchSpacing/2)-0.25-((nWindows/2)*BunchSpacing) #Random low 2
    RandomWindows[1][0][x] = PromptPeak[x]+(BunchSpacing/2)+0.25+((nWindows/2)*BunchSpacing) #Random high 1
    RandomWindows[1][1][x] = PromptPeak[x]+(BunchSpacing/2)+0.25+((nWindows)*BunchSpacing) #Random high 2

def hms_elec():
    # Define the array of arrays containing the relevant HMS info
    NoCut_HMS_Elec = [H_gtr_beta, H_gtr_xp, H_gtr_yp, H_gtr_dp, H_cal_etotnorm, H_cer_npesum]
    # Create array of arrays of variables after cuts
    Cut_HMS_Elec = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer)
                    for (HBeta, Hxp, Hyp, Hdel, HCal, HCer) in zip(*NoCut_HMS_Elec)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5]

    HMS_Electrons = {
        "Uncut_Events" : NoCut_HMS_Elec,
        "Cut_Events" : Cut_HMS_Elec,
    }

    return HMS_Electrons

def shms_pions(): 
    # Define the array of arrays containing the relevant SHMS info
    NoCut_SHMS_Pions = [H_gtr_beta, H_gtr_xp, H_gtr_yp, H_gtr_dp, H_cal_etotnorm, H_cer_npesum, CTime_ePiCoinTime_ROC1, P_RF_tdcTime, P_hod_fpHitsTime, P_gtr_beta, P_gtr_xp, P_gtr_yp, P_gtr_p, P_gtr_dp, P_cal_etotnorm, P_aero_npeSum, P_hgcer_npeSum, P_hgcer_xAtCer, P_hgcer_yAtCer, MMpi, MMK, MMp]
    # Create array of arrays of pions after cuts, all events, prompt and random
    Cut_SHMS_Pions_all = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTPi, RF, HodStart, PiBeta, Pixp, Piyp, PiP, PiDel, PiCal, PiAero, PiHGC, PiHGCX, PiHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTPi, RF, HodStart, PiBeta, Pixp, Piyp, PiP, PiDel, PiCal, PiAero, PiHGC, PiHGCX, PiHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Pions)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if PiDel > -10 and PiDel < 20
                    if abs(Pixp) < 0.06
                    if abs(Piyp) < 0.04
                    if abs(PiBeta -1.0) < 0.3
                    if PiAero > 1.5
                    if PiHGC > 1.5]
                    # need to add RF timing cut, need to implement database idea
    # Create array of arrays of pions after cuts, prompt events
    # NOTE - Should just be able to feed all events array into this somehow? Should investigate
    Cut_SHMS_Pions_prompt = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTPi, RF, HodStart, PiBeta, Pixp, Piyp, PiP, PiDel, PiCal, PiAero, PiHGC, PiHGCX, PiHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTPi, RF, HodStart, PiBeta, Pixp, Piyp, PiP, PiDel, PiCal, PiAero, PiHGC, PiHGCX, PiHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Pions)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if PiDel > -10 and PiDel < 20
                    if abs(Pixp) < 0.06
                    if abs(Piyp) < 0.04
                    if abs(PiBeta -1.0) < 0.3
                    if PiAero > 1.5
                    if PiHGC > 1.5
                    if CTPi > (PromptPeak[0]-((BunchSpacing/2)+0.25)) and CTPi < (PromptPeak[0]+((BunchSpacing/2)+0.25))]
    # Create array of arrays of pions after cuts, random events    
    Cut_SHMS_Pions_random = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTPi, RF, HodStart, PiBeta, Pixp, Piyp, PiP, PiDel, PiCal, PiAero, PiHGC, PiHGCX, PiHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTPi, RF, HodStart, PiBeta, Pixp, Piyp, PiP, PiDel, PiCal, PiAero, PiHGC, PiHGCX, PiHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Pions)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if PiDel > -10 and PiDel < 20
                    if abs(Pixp) < 0.06
                    if abs(Piyp) < 0.04
                    if abs(PiBeta -1.0) < 0.3
                    if PiAero > 1.5
                    if PiHGC > 1.5
                    if (CTPi > RandomWindows[0][0][0] and CTPi < RandomWindows[0][1][0]) or (CTPi > RandomWindows[1][0][0] and CTPi < RandomWindows[1][1][0])]

    SHMS_Pions = {
        "Uncut_Events" : NoCut_SHMS_Pions,
        "Cut_Events_All" : Cut_SHMS_Pions_all,
        "Cut_Events_Prompt" : Cut_SHMS_Pions_prompt,
        "Cut_Events_Random" : Cut_SHMS_Pions_random,
    }

    return SHMS_Pions

def shms_kaons(): 
    # Define the array of arrays containing the relevant SHMS info
    NoCut_SHMS_Kaons = [H_gtr_beta, H_gtr_xp, H_gtr_yp, H_gtr_dp, H_cal_etotnorm, H_cer_npesum, CTime_eKCoinTime_ROC1, P_RF_tdcTime, P_hod_fpHitsTime, P_gtr_beta, P_gtr_xp, P_gtr_yp, P_gtr_p, P_gtr_dp, P_cal_etotnorm, P_aero_npeSum, P_hgcer_npeSum, P_hgcer_xAtCer, P_hgcer_yAtCer, MMpi, MMK, MMp]
    # Create array of arrays of pions after cuts, all events, prompt and random
    Cut_SHMS_Kaons_all = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTK, RF, HodStart, KBeta, Kxp, Kyp, KP, KDel, KCal, KAero, KHGC, KHGCX, KHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTK, RF, HodStart, KBeta, Kxp, Kyp, KP, KDel, KCal, KAero, KHGC, KHGCX, KHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Kaons)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if KDel > -10 and KDel < 20
                    if abs(Kxp) < 0.06
                    if abs(Kyp) < 0.04
                    if abs(KBeta -1.0) < 0.3
                    if KAero > 1.5
                    if KHGC > 1.5]
                    # need to add RF timing cut, need to implement database idea
    # Create array of a/rrays of pions after cuts, prompt events
    # NOTE - Should just be able to feed all events array into this somehow? Should investigate
    Cut_SHMS_Kaons_prompt = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTK, RF, HodStart, KBeta, Kxp, Kyp, KP, KDel, KCal, KAero, KHGC, KHGCX, KHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTK, RF, HodStart, KBeta, Kxp, Kyp, KP, KDel, KCal, KAero, KHGC, KHGCX, KHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Kaons)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if KDel > -10 and KDel < 20
                    if abs(Kxp) < 0.06
                    if abs(Kyp) < 0.04
                    if abs(KBeta -1.0) < 0.3
                    if KAero > 1.5
                    if KHGC > 1.5
                    if CTK > (PromptPeak[1]-((BunchSpacing/2)+0.25)) and CTK < (PromptPeak[1]+((BunchSpacing/2)+0.25))]
    # Create array of arrays of pions after cuts, random events    
    Cut_SHMS_Kaons_random = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTK, RF, HodStart, KBeta, Kxp, Kyp, KP, KDel, KCal, KAero, KHGC, KHGCX, KHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTK, RF, HodStart, KBeta, Kxp, Kyp, KP, KDel, KCal, KAero, KHGC, KHGCX, KHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Kaons)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if KDel > -10 and KDel < 20
                    if abs(Kxp) < 0.06
                    if abs(Kyp) < 0.04
                    if abs(KBeta -1.0) < 0.3
                    if KAero > 1.5
                    if KHGC > 1.5
                    if (CTK > RandomWindows[0][0][1] and CTK < RandomWindows[0][1][1]) or (CTK > RandomWindows[1][0][1] and CTK < RandomWindows[1][1][1])]

    SHMS_Kaons = {
        "Uncut_Events" : NoCut_SHMS_Kaons,
        "Cut_Events_All" : Cut_SHMS_Kaons_all,
        "Cut_Events_Prompt" : Cut_SHMS_Kaons_prompt,
        "Cut_Events_Random" : Cut_SHMS_Kaons_random,
    }

    return SHMS_Kaons

def shms_protons(): 
    # Define the array of arrays containing the relevant SHMS info
    NoCut_SHMS_Protons = [H_gtr_beta, H_gtr_xp, H_gtr_yp, H_gtr_dp, H_cal_etotnorm, H_cer_npesum, CTime_epCoinTime_ROC1, P_RF_tdcTime, P_hod_fpHitsTime, P_gtr_beta, P_gtr_xp, P_gtr_yp, P_gtr_p, P_gtr_dp, P_cal_etotnorm, P_aero_npeSum, P_hgcer_npeSum, P_hgcer_xAtCer, P_hgcer_yAtCer, MMpi, MMK, MMp]
    # Create array of arrays of pions after cuts, all events, prompt and random
    Cut_SHMS_Protons_all = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTp, RF, HodStart, pBeta, pxp, pyp, pP, pDel, pCal, pAero, pHGC, pHGCX, pHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTp, RF, HodStart, pBeta, pxp, pyp, pP, pDel, pCal, pAero, pHGC, pHGCX, pHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Protons)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if pDel > -10 and pDel < 20
                    if abs(pxp) < 0.06
                    if abs(pyp) < 0.04
                    if abs(pBeta -1.0) < 0.3
                    if pAero > 1.5
                    if pHGC > 1.5]
                    # need to add RF timing cut, need to implement database idea
    # Create array of a/rrays of pions after cuts, prompt events
    # NOTE - Should just be able to feed all events array into this somehow? Should investigate
    Cut_SHMS_Protons_prompt = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTp, RF, HodStart, pBeta, pxp, pyp, pP, pDel, pCal, pAero, pHGC, pHGCX, pHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTp, RF, HodStart, pBeta, pxp, pyp, pP, pDel, pCal, pAero, pHGC, pHGCX, pHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Protons)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if pDel > -10 and pDel < 20
                    if abs(pxp) < 0.06
                    if abs(pyp) < 0.04
                    if abs(pBeta -1.0) < 0.3
                    if pAero > 1.5
                    if pHGC > 1.5
                    if CTp > (PromptPeak[2]-((BunchSpacing/2)+0.25)) and CTp < (PromptPeak[2]+((BunchSpacing/2)+0.25))]
    # Create array of arrays of pions after cuts, random events    
    Cut_SHMS_Protons_random = [(HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTp, RF, HodStart, pBeta, pxp, pyp, pP, pDel, pCal, pAero, pHGC, pHGCX, pHGCY, mm1, mm2, mm3) for (HBeta, Hxp, Hyp, Hdel, HCal, HCer, CTp, RF, HodStart, pBeta, pxp, pyp, pP, pDel, pCal, pAero, pHGC, pHGCX, pHGCY, mm1, mm2, mm3) in zip(*NoCut_SHMS_Protons)
                    if abs(Hdel) < 8
                    if abs(Hxp) < 0.08
                    if abs(Hyp) < 0.045
                    if HCal > 0.7 and HCal <1.5
                    if pDel > -10 and pDel < 20
                    if abs(pxp) < 0.06
                    if abs(pyp) < 0.04
                    if abs(pBeta -1.0) < 0.3
                    if pAero > 1.5
                    if pHGC > 1.5
                    if (CTp > RandomWindows[0][0][2] and CTp < RandomWindows[0][1][2]) or (CTp > RandomWindows[1][0][2] and CTp < RandomWindows[1][1][2])]

    SHMS_Protons = {
        "Uncut_Events" : NoCut_SHMS_Protons,
        "Cut_Events_All" : Cut_SHMS_Protons_all,
        "Cut_Events_Prompt" : Cut_SHMS_Protons_prompt,
        "Cut_Events_Random" : Cut_SHMS_Protons_random,
    }

    return SHMS_Protons

def main():
    HMS_Elec_Data = hms_elec()
    SHMS_Pion_Data = shms_pions()
    SHMS_Kaon_Data = shms_kaons()
    SHMS_Proton_Data = shms_protons()
if __name__ == '__main__':
    main()    
