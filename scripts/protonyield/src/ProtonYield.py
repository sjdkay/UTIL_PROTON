#! /usr/bin/python

# 20/4/20 - Stephen Kay, University of Regina

# Python version of the proton analysis script. Now utilises uproot to select event of each type and writes them to a root file
# Intention is to apply PID/selection cutting here and plot in a separate script
# Python should allow for easier reading of databases storing timing offsets e.t.c.

import uproot as up
import numpy as np
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
