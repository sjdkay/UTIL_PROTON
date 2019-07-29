#define ProtonYield_cxx
// The class definition in ProtonYield.h has been generated automatically
// by the ROOT utility TTree::MakeSelector(). This class is derived
// from the ROOT class TSelector. For more information on the TSelector
// framework see $ROOTSYS/README/README.SELECTOR or the ROOT User Manual.

// The following methods are defined in this file:
//    Begin():        called every time a loop on the tree starts,
//                    a convenient place to create your histograms.
//    SlaveBegin():   called after Begin(), when on PROOF called only on the
//                    slave servers.
//    Process():      called for each event, in this function you decide what
//                    to read and fill your histograms.
//    SlaveTerminate: called at the end of the loop on the tree, when on PROOF
//                    called only on the slave servers.
//    Terminate():    called at the end of the loop on the tree,
//                    a convenient place to draw/fit your histograms.
//
// To use this file, try the following session on your Tree T:
//
// root> T->Process("ProtonYield.C")
// root> T->Process("ProtonYield.C","some options")
// root> T->Process("ProtonYield.C+")

#include "ProtonYield.h"
#include <TStyle.h>
#include <TCanvas.h>
#include <TLine.h>
#include <TMath.h>
#include <TPaveText.h>
#include <TGaxis.h>

void ProtonYield::Begin(TTree * /*tree*/)
{
  // The Begin() function is called at the start of the query.
  // When running with PROOF Begin() is only called on the client.
  // The tree argument is deprecated (on PROOF 0 is passed).
  TString option = GetOption();
}

void ProtonYield::SlaveBegin(TTree * /*tree*/)
{
  // The SlaveBegin() function is called after the Begin() function.
  // When running with PROOF SlaveBegin() is called on each slave server.
  // The tree argument is deprecated (on PROOF 0 is passed).

  TString option = GetOption();

  h2missKcut_CT   = new TH2F("h1missKcut_CT","Kaon Missing mass vs Coincidence Time;Time (ns);Mass (GeV/c^{2})^{2}",400,-10,10,200,0.8,1.5);
  h2misspicut_CT   = new TH2F("h1misspicut_CT","Pion Missing mass vs Coincidence Time;Time (ns);Mass (GeV/c^{2})^{2}",400,-10,10,200,0.8,1.5);

  h2ROC1_Coin_Beta_noID_kaon = new TH2F("ROC1_Coin_Beta_noCut_kaon","Kaon Coincident Time vs #beta for ROC1 (w/ particle ID);Time (ns);#beta",800,-40,40,200,0.0,2.0);
  h2ROC1_Coin_Beta_kaon = new TH2F("ROC1_Coin_Beta_kaon","Kaon Coincident Time vs #beta for ROC1;Time (ns);#beta",800,-40,40,200,0.0,2.0);
  h2ROC1_Coin_Beta_noID_pion = new TH2F("ROC1_Coin_Beta_noCut_pion","Pion Coincident Time vs #beta for ROC1 (w/ particle ID);Time (ns);#beta",400,-20,20,100,0.0,2.0);
  h2ROC1_Coin_Beta_pion = new TH2F("ROC1_Coin_Beta_pion","Pion Coincident Time vs #beta for ROC1;Time (ns);#beta",400,-20,20,100,0.0,2.0);
  h2ROC1_Coin_Beta_noID_proton = new TH2F("ROC1_Coin_Beta_noCut_proton","Proton Coincident Time vs #beta for ROC1 (w/ particle ID);Time (ns);#beta",800,-40,40,200,0.0,2.0);
  h2ROC1_Coin_Beta_proton = new TH2F("ROC1_Coin_Beta_proton","Proton Coincident Time vs #beta for ROC1;Time (ns);#beta",800,-40,40,200,0.0,2.0);

  h2HMS_electron        = new TH2F("HMS_electron","Normalized HMS Calorimeter Energy vs Cherenkov;Normalized Energy;CER NPE",200,0.01,1.5,60,0.1,30);
  h2HMS_electron_cut    = new TH2F("HMS_electron_cut","Normalized HMS Calorimeter Energy vs Cherenkov, Electrons Selected;Normalized Energy;CER NPE",200,0.01,1.5,60,0.0,30);

  h1SHMS_electron        = new TH1F("SHMS_electron","Normalized SHMS Calorimeter Energy;Normalized Energy;Counts",200,0.01,1.5);
  h1SHMS_electron_cut    = new TH1F("SHMS_electron_cut","Normalized SHMS Calorimeter Energy, Electrons Removed;Normalized Energy;Counts",200,0.01,1.5);

  h2SHMS_AERO_HGC         = new TH2F("SHMS_AERO_HGC","NPE in SHMS Aerogel and Heavy Gas;Aerogel NPE;HGC NPE",50,0.1,25,50,0.1,30);
  h2SHMS_CAL_HGC         = new TH2F("SHMS_CAL_HGC","Normalized SHMS Calorimeter Energy and NPE in Heavy Gas;Normalized Energy;HGC NPE",50,0.1,2.0,50,-1,30);

  h2SHMSK_kaon_cut        = new TH2F("SHMSK_kaon_cut","NPE in SHMS Aerogel and Heavy Gas, Kaons Selected;Aerogel NPE;HGC NPE",50,0.0,25,50,0.0,10);
  h2SHMSK_pion_cut        = new TH2F("SHMSK_pion_cut","Normalized SHMS Calorimeter Energy and NPE in Heavy Gas, Kaons Selected;Normalized Energy;HGC NPE",50,0.0,2.0,50,-1.0,30);

  h2SHMSpi_kaon_cut        = new TH2F("SHMSpi_kaon_cut","NPE in SHMS Aerogel and Heavy Gas, Pions Selected;Aerogel NPE;HGC NPE",50,0.0,25,150,0.0,30);
  h2SHMSpi_pion_cut        = new TH2F("SHMSpi_pion_cut","Normalized SHMS Calorimeter Energy and NPE in Heavy Gas, Pions Selected;Normalized Energy;HGC NPE",50,0.0,2.0,50,-1.0,30);

  h2SHMSp_kaon_cut        = new TH2F("SHMSp_kaon_cut","NPE in SHMS Aerogel and Heavy Gas, Protons Selected; Aerogel NPE;HGC NPE",50,0.0,25,50,0.0,10);
  h2SHMSp_pion_cut        = new TH2F("SHMSp_pion_cut","Normalized SHMS Calorimeter Energy and NPE in Heavy Gas, Protons Selected;Normalized Energy;HGC NPE",50,0.0,2.0,50,0.0,30);

  h1SHMS_delta           = new TH1F("SHMS_delta","SHMS #delta;#delta;Counts",100,-50,50);
  h1SHMS_delta_cut       = new TH1F("SHMS_delta_cut","SHMS #delta Cut;#delta;Counts",100,-50,50);
  h1HMS_delta            = new TH1F("HMS_delta","HMS #delta;#delta;Counts",100,-50,50);
  h1HMS_delta_cut        = new TH1F("HMS_delta_cut","HMS #delta Cut;#delta;Counts",100,-50,50);

  h1SHMS_th              = new TH1F("SHMS_th","SHMS #theta Acceptance;#theta;Counts",100,-0.1,0.1);
  h1SHMS_th_cut          = new TH1F("SHMS_th_cut","SHMS #theta Acceptance with Cut;#theta;Counts",100,-0.1,0.1);
  h1SHMS_ph              = new TH1F("SHMS_ph","SHMS #phi Acceptance;#phi;Counts",100,-0.1,0.1);
  h1SHMS_ph_cut          = new TH1F("SHMS_ph_cut","SHMS #phi Acceptance with Cut;#phi;Counts",100,-0.1,0.1);

  h1HMS_th              = new TH1F("HMS_th","HMS #theta Acceptance;#theta;Counts",100,-0.1,0.1);
  h1HMS_th_cut          = new TH1F("HMS_th_cut","HMS #theta Acceptance with Cut;#theta;Counts",100,-0.1,0.1);
  h1HMS_ph              = new TH1F("HMS_ph","HMS #phi Acceptance;#phi;Counts",100,-0.1,0.1);
  h1HMS_ph_cut          = new TH1F("HMS_ph_cut","HMS #phi Acceptance with Cut;#phi;Counts",100,-0.1,0.1);

  h1mmissK                = new TH1F("mmissK","Kaon Missing mass;Mass (GeV/c^{2});Counts",200,0.8,2.0);
  h1mmissK_rand           = new TH1F("mmissK_rand","Kaon Missing mass from Random Coincidence;Mass (GeV/c^{2});Counts",200,0.8,1.8);
  h1mmissK_cut            = new TH1F("mmissK_cut","Kaon Missing mass with Cuts;Mass (GeV/c^{2});Counts",200,0.8,1.8);
  h1mmissK_remove         = new TH1F("mmissK_remove","Kaon Missing mass with Cuts (Random Subtracted);Mass (GeV/c^{2});Counts",200,0.8,1.8);

  h1mmisspi               = new TH1F("mmisspi","Pion Missing mass;Mass (GeV/c^{2});Counts",200,0.8,1.2);
  h1mmisspi_rand          = new TH1F("mmisspi_rand","Pion Missing mass from Random Coincidence;Mass (GeV/c^{2});Counts",200,0.8,1.2);
  h1mmisspi_cut           = new TH1F("mmisspi_cut","Pion Missing mass with Cuts;Mass (GeV/c^{2});Counts",200,0.8,1.2);
  h1mmisspi_remove        = new TH1F("mmisspi_remove","Pion Missing mass with Cuts (Random Subtracted);Mass (GeV/c^{2});Counts",200,0.8,1.2);

  h1mmissp                = new TH1F("mmissp","Proton Missing mass;Mass (GeV/c^{2});Counts",200,0.0,2.0);
  h1mmissp_rand           = new TH1F("mmissp_rand","Proton Missing mass from Random Coincidence;Mass (GeV/c^{2});Counts",200,0.0,2.0);
  h1mmissp_cut            = new TH1F("mmissp_cut","Proton Missing mass with Cuts;Mass (GeV/c^{2});Counts",200,0.0,2.0);
  h1mmissp_remove         = new TH1F("mmissp_remove","Proton Missing mass with Cuts (Random Subtracted);Mass (GeV/c^{2});Counts",200,0.0,2.0);

  //  h2WvsQ2                 = new TH2F("WvsQ2","Q2 vs W;Q2;W",200,1.0,1.8,200,1.8,2.4);
  h2WvsQ2                 = new TH2F("WvsQ2","Q2 vs W;Q2;W",200,1,3,200,1.8,2.4);
  h2tvsph_q               = new TH2F("tvsph_q",";#phi;t",12,-3.14,3.14,16,0.0,0.4); // Increased Ymax to 0.1 SK 28/6/19
  h1epsilon               = new TH1F("epsilon","Plot of Epsilon;#epsilon;Counts",100,0.0,1.0);

  h1EDTM                  = new TH1F("EDTM","EDTM Time;EDTM TDC Time;Counts",10000,-5000,5000);
  h1TRIG5                 = new TH1F("TRIG5","TRIG5 Time;TRIG5 TDC Time;Counts",10000,-5000,5000);

  GetOutputList()->Add(h2missKcut_CT);
  GetOutputList()->Add(h2misspicut_CT);
  GetOutputList()->Add(h2ROC1_Coin_Beta_noID_kaon);
  GetOutputList()->Add(h2ROC1_Coin_Beta_kaon);
  GetOutputList()->Add(h2ROC1_Coin_Beta_noID_pion);
  GetOutputList()->Add(h2ROC1_Coin_Beta_pion);
  GetOutputList()->Add(h2ROC1_Coin_Beta_noID_proton);
  GetOutputList()->Add(h2ROC1_Coin_Beta_proton);
  GetOutputList()->Add(h2HMS_electron);
  GetOutputList()->Add(h2HMS_electron_cut);
  GetOutputList()->Add(h1SHMS_electron);
  GetOutputList()->Add(h1SHMS_electron_cut);
  GetOutputList()->Add(h2SHMS_AERO_HGC);
  GetOutputList()->Add(h2SHMS_CAL_HGC);
  GetOutputList()->Add(h2SHMSK_kaon_cut);
  GetOutputList()->Add(h2SHMSK_pion_cut);
  GetOutputList()->Add(h2SHMSpi_kaon_cut);
  GetOutputList()->Add(h2SHMSpi_pion_cut);
  GetOutputList()->Add(h2SHMSp_kaon_cut);
  GetOutputList()->Add(h2SHMSp_pion_cut);
  GetOutputList()->Add(h1SHMS_delta);
  GetOutputList()->Add(h1SHMS_delta_cut);
  GetOutputList()->Add(h1HMS_delta);
  GetOutputList()->Add(h1HMS_delta_cut);
  GetOutputList()->Add(h1SHMS_th);
  GetOutputList()->Add(h1SHMS_th_cut);
  GetOutputList()->Add(h1SHMS_ph);
  GetOutputList()->Add(h1SHMS_ph_cut);
  GetOutputList()->Add(h1HMS_th);
  GetOutputList()->Add(h1HMS_th_cut);
  GetOutputList()->Add(h1HMS_ph);
  GetOutputList()->Add(h1HMS_ph_cut);
  GetOutputList()->Add(h1mmissK);
  GetOutputList()->Add(h1mmissK_rand);
  GetOutputList()->Add(h1mmissK_cut);
  GetOutputList()->Add(h1mmissK_remove);
  GetOutputList()->Add(h1mmisspi);
  GetOutputList()->Add(h1mmisspi_rand);
  GetOutputList()->Add(h1mmisspi_cut);
  GetOutputList()->Add(h1mmisspi_remove);
  GetOutputList()->Add(h1mmissp);
  GetOutputList()->Add(h1mmissp_rand);
  GetOutputList()->Add(h1mmissp_cut);
  GetOutputList()->Add(h1mmissp_remove);
  GetOutputList()->Add(h2WvsQ2);
  GetOutputList()->Add(h2tvsph_q);
  GetOutputList()->Add(h1epsilon);
  GetOutputList()->Add(h1EDTM);
  GetOutputList()->Add(h1TRIG5);
}

Bool_t ProtonYield::Process(Long64_t entry)
{
  fReader.SetEntry(entry);

  // Fill some histograms before applying any cuts
  h1EDTM->Fill(*pEDTM);
  h2HMS_electron->Fill(H_cal_etotnorm[0],H_cer_npeSum[0]);
  h1SHMS_electron->Fill(P_cal_etotnorm[0]);
  h2SHMS_AERO_HGC->Fill(P_aero_npeSum[0],P_hgcer_npeSum[0]);
  h2SHMS_CAL_HGC->Fill(P_cal_etotnorm[0],P_hgcer_npeSum[0]);
  h1SHMS_delta->Fill(P_gtr_dp[0]);
  h1HMS_delta->Fill(H_gtr_dp[0]);
  h1SHMS_th->Fill(P_gtr_th[0]);
  h1SHMS_ph->Fill(P_gtr_ph[0]);
  h1HMS_th->Fill(H_gtr_th[0]);
  h1HMS_ph->Fill(H_gtr_ph[0]);
  // This analysis operates on runs that have been analysed as though a kaon is going into the SHMS
  Double_t MMp = sqrt(pow(emiss[0] + sqrt(pow(0.493677,2) + pow(P_gtr_p[0],2)) - sqrt(pow(0.93828,2) + pow(P_gtr_p[0],2)),2)-pow(pmiss[0],2)); // Calculate missing mass under condition that hadron is a proton
  Double_t MMPi = sqrt(pow(emiss[0] + sqrt(pow(0.493677,2) + pow(P_gtr_p[0],2)) - sqrt(pow(0.13957018,2) + pow(P_gtr_p[0],2)),2)-pow(pmiss[0],2)); // Calculate missing mass under condition that hadron is a kaon 
  Double_t MMK = sqrt(pow(emiss[0],2)-pow(pmiss[0],2)); // Calculate missing mass under condition that hadron is a pion
  h1mmissK->Fill(MMK);
  h1mmisspi->Fill(MMPi);
  h1mmissp->Fill(MMp);

  // Cuts that all particle species share in common
  // if (P_cal_etotnorm[0] > 0.6) return kTRUE; // Check SHMS doesn't see a positron
  if (H_cal_etotnorm[0] < 0.4 || H_cer_npeSum[0] < 1.5) return kTRUE; // Check HMS sees an electron
  //  if (H_gtr_dp[0] > 17.0 || H_gtr_dp[0] < -13.0) return kTRUE;
  if (H_gtr_dp[0] > 8.0 || H_gtr_dp[0] < -8.0) return kTRUE; // add HMS delta cuts
  if (P_gtr_dp[0] > 20.0 || P_gtr_dp[0] < -10.0) return kTRUE; // Cut on delta
  if (TMath::Abs(P_gtr_th[0]) > 0.060) return kTRUE; // Cut on theta/phi for SHMS/HMS, broadened from 0.4/0.024 to current values
  if (TMath::Abs(P_gtr_ph[0]) > 0.040) return kTRUE; // Without these we see too much crap in the t-phi plot
  if (TMath::Abs(H_gtr_th[0]) > 0.080) return kTRUE; // Keep them in, they will need tweaking in future
  if (TMath::Abs(H_gtr_ph[0]) > 0.045) return kTRUE;

  // Fill histograms with events AFTER doing our common cuts
  h2HMS_electron_cut->Fill(H_cal_etotnorm[0],H_cer_npeSum[0]);
  h1SHMS_electron_cut->Fill(P_cal_etotnorm[0]);
  h1SHMS_delta_cut->Fill(P_gtr_dp[0]);
  h1HMS_delta_cut->Fill(H_gtr_dp[0]);
  h1SHMS_th_cut->Fill(P_gtr_th[0]);
  h1SHMS_ph_cut->Fill(P_gtr_ph[0]);
  h1HMS_th_cut->Fill(H_gtr_th[0]);
  h1HMS_ph_cut->Fill(H_gtr_ph[0]);

  //Event identified as Kaon
  if (P_aero_npeSum[0] > 1.5 && P_hgcer_npeSum[0] < 1.5) {
    h2ROC1_Coin_Beta_noID_kaon->Fill((CTime_eKCoinTime_ROC1[0] - 43),P_gtr_beta[0]); 
    if (abs(P_gtr_beta[0]-1.00) > 0.1) return kTRUE;
    h2missKcut_CT->Fill( CTime_eKCoinTime_ROC1[0] - 43, MMK);
    if ( (CTime_eKCoinTime_ROC1[0] - 43) > -1.0 && (CTime_eKCoinTime_ROC1[0] - 43) < 1.5) {
      h2ROC1_Coin_Beta_kaon->Fill((CTime_eKCoinTime_ROC1[0] - 43),P_gtr_beta[0]);
      h2SHMSK_kaon_cut->Fill(P_aero_npeSum[0],P_hgcer_npeSum[0]);
      h2SHMSK_pion_cut->Fill(P_cal_etotnorm[0],P_hgcer_npeSum[0]);
      h1mmissK_cut->Fill(MMK);
    }
    if ((((CTime_eKCoinTime_ROC1[0] - 43) > -21.0 && (CTime_eKCoinTime_ROC1[0] - 43) < -9.0))) {
      h1mmissK_rand->Fill(MMK);
      h1mmissK_remove->Fill(MMK);
    }
  }

  //Event identified as Pion
  if (P_hgcer_npeSum[0] > 1.5 && P_aero_npeSum[0] > 1.5) { 
    //if (P_aero_npeSum[0] > 1.5) { 
    h2ROC1_Coin_Beta_noID_pion->Fill((CTime_ePiCoinTime_ROC1[0] - 44.15),P_gtr_beta[0]);
    if (abs(P_gtr_beta[0]-1.00) > 0.3) return kTRUE;
    h2misspicut_CT->Fill( CTime_ePiCoinTime_ROC1[0] - 44.15, MMPi);
    if (abs((CTime_ePiCoinTime_ROC1[0] - 44.15)) < 1) {
      h2ROC1_Coin_Beta_pion->Fill((CTime_ePiCoinTime_ROC1[0] - 44.15),P_gtr_beta[0]);
      h2SHMSpi_kaon_cut->Fill(P_aero_npeSum[0],P_hgcer_npeSum[0]);
      h2SHMSpi_pion_cut->Fill(P_cal_etotnorm[0],P_hgcer_npeSum[0]);
      h1mmisspi_cut->Fill(MMPi);
      h2WvsQ2->Fill(Q2[0],W[0]);
      h2tvsph_q->Fill(ph_q[0],-MandelT[0]);
      h1epsilon->Fill(epsilon[0]);
    }
    if (abs((CTime_ePiCoinTime_ROC1[0] - 44.15)) > 5.0 && abs((CTime_ePiCoinTime_ROC1[0] - 44.15)) < 19.0) {
      h1mmisspi_rand->Fill(MMPi);
      h1mmisspi_remove->Fill(MMPi);
    }
  }

  //Event identified as Proton
  if (P_aero_npeSum[0] < 1.5 && P_hgcer_npeSum[0] < 1.5) {
    h2ROC1_Coin_Beta_noID_proton->Fill((CTime_epCoinTime_ROC1[0] - 43.5),P_gtr_beta[0]);
    if (abs(P_gtr_beta[0]-1.00) > 0.1) return kTRUE;
    if (abs((CTime_epCoinTime_ROC1[0] - 43.5)) < 1.0) {
      h2ROC1_Coin_Beta_proton->Fill((CTime_epCoinTime_ROC1[0] - 43.5),P_gtr_beta[0]);
      h2SHMSp_kaon_cut->Fill(P_aero_npeSum[0],P_hgcer_npeSum[0]);
      h2SHMSp_pion_cut->Fill(P_cal_etotnorm[0],P_hgcer_npeSum[0]);
      h1mmissp_cut->Fill(MMp);
    }
    if (abs((CTime_epCoinTime_ROC1[0] - 43.5)) > 6.0 && abs((CTime_epCoinTime_ROC1[0] - 43.5)) < 20.0) {
      h1mmissp_rand->Fill(MMp);
      h1mmissp_remove->Fill(MMp);
    }
  }
  return kTRUE;
}

void ProtonYield::SlaveTerminate()
{
  // The SlaveTerminate() function is called after all entries or objects
  // have been processed. When running with PROOF SlaveTerminate() is called
  // on each slave server.
}

void ProtonYield::Terminate()
{
  TString option = GetOption();
  TH1F* EDTM = dynamic_cast<TH1F*> (GetOutputList()->FindObject("EDTM"));
  TH2F* HMS_electron = dynamic_cast<TH2F*> (GetOutputList()->FindObject("HMS_electron"));
  TH2F* HMS_electron_cut = dynamic_cast<TH2F*> (GetOutputList()->FindObject("HMS_electron_cut"));

  //Perform Random Subtraction, these windows will likely need to be adjusted
  h1mmissK_rand->Scale(1.0/3.0);
  h1mmisspi_rand->Scale(1.0/7.0); // Are these scales correct? How many buckets do we capture?
  h1mmissp_rand->Scale(1.25/7.0);
  h1mmissK_remove->Add(h1mmissK_cut,h1mmissK_rand,1,-1);
  h1mmisspi_remove->Add(h1mmisspi_cut,h1mmisspi_rand,1,-1);
  h1mmissp_remove->Add(h1mmissp_cut,h1mmissp_rand,1,-1);
  
  // Provide a full path?
  TString foutname = Form("../OUTPUT/Proton_Kinematics_Run%i_AllPlots", option.Atoi());
  TString outputpng = foutname + ".png";
  TString outputpng_coin = foutname + "_coin.png";
  TString outputpdf = foutname + ".pdf";
  
  TCanvas *cCuts = new TCanvas("Cuts","Summary of Common Cuts",100,0,1000,900);
  cCuts->Divide(2,4);
  cCuts->cd(1); h1HMS_delta->Draw();
  cCuts->cd(2); h1HMS_delta_cut->Draw();
  cCuts->cd(3); h1SHMS_delta->Draw();
  cCuts->cd(4); h1SHMS_delta_cut->Draw();
  cCuts->cd(5); HMS_electron->Draw("Colz");
  cCuts->cd(6); HMS_electron_cut->Draw("Colz");
  cCuts->cd(7); h1SHMS_electron->Draw();
  cCuts->cd(8); h1SHMS_electron_cut->Draw();
  cCuts->Print(outputpdf + '(');

  TCanvas *cAngles = new TCanvas("Angles","Summary of Angular Cuts",200,50,1000,900);
  cAngles->Divide(2,4);
  cAngles->cd(1); h1HMS_th->Draw();
  cAngles->cd(2); h1HMS_th_cut->Draw();
  cAngles->cd(3); h1HMS_ph->Draw();
  cAngles->cd(4); h1HMS_ph_cut->Draw();
  cAngles->cd(5); h1SHMS_th->Draw();
  cAngles->cd(6); h1SHMS_th_cut->Draw();
  cAngles->cd(7); h1SHMS_ph->Draw();
  cAngles->cd(8); h1SHMS_ph_cut->Draw();
  cAngles->Print(outputpdf);

  TCanvas *cpiID = new TCanvas("piID","Summary of Pion Particle ID Cuts",300,100,1000,900);
  cpiID->Divide(2,4);
  cpiID->cd(1); h2SHMS_AERO_HGC->Draw("Colz");
  cpiID->cd(2); h2SHMSpi_kaon_cut->Draw("Colz");
  cpiID->cd(3); h2SHMS_CAL_HGC->Draw("Colz");
  cpiID->cd(4); h2SHMSpi_pion_cut->Draw("Colz");
  cpiID->cd(5); h2ROC1_Coin_Beta_noID_pion->Draw("Colz");
  cpiID->Update();
  TLine *piLowerRand = new TLine(5.0,gPad->GetUymin(),5.0,gPad->GetUymax()); 
  piLowerRand->SetLineColor(kRed); piLowerRand->SetLineWidth(1); piLowerRand->Draw();
  TLine *piUpperRand = new TLine(19.0,gPad->GetUymin(),19.0,gPad->GetUymax());  
  piUpperRand->SetLineColor(kRed); piUpperRand->SetLineWidth(1); piUpperRand->Draw();
  cpiID->cd(6); h2ROC1_Coin_Beta_pion->Draw("Colz");
  cpiID->cd(7); h1mmisspi->Draw();
  cpiID->cd(8); h1mmisspi_remove->Draw("hist");
  cpiID->Update();
  cpiID->Print(outputpdf);

  TCanvas *cKID = new TCanvas("KID","Summary of Kaon Particle ID Cuts",300,100,1000,900);
  cKID->Divide(2,4);
  cKID->cd(1); h2SHMS_AERO_HGC->Draw("Colz");
  cKID->cd(2); h2SHMSK_kaon_cut->Draw("Colz");
  cKID->cd(3); h2SHMS_CAL_HGC->Draw("Colz");
  cKID->cd(4); h2SHMSK_pion_cut->Draw("Colz");
  cKID->cd(5); h2ROC1_Coin_Beta_noID_kaon->Draw("Colz");
  cKID->Update();
  TLine *KLowerRand = new TLine(-21,gPad->GetUymin(),-21,gPad->GetUymax()); 
  KLowerRand->SetLineColor(kRed); KLowerRand->SetLineWidth(1); KLowerRand->Draw();
  TLine *KUpperRand = new TLine(-9.0,gPad->GetUymin(),-9.0,gPad->GetUymax());  
  KUpperRand->SetLineColor(kRed); KUpperRand->SetLineWidth(1); KUpperRand->Draw();
  cKID->cd(6); h2ROC1_Coin_Beta_kaon->Draw("Colz");
  cKID->cd(7); h1mmissK->Draw();
  cKID->cd(8); h1mmissK_remove->Draw("hist");
  cKID->Update();
  cKID->Print(outputpdf);

  TCanvas *cpID = new TCanvas("pID","Summary of Proton Particle ID Cuts",300,100,1000,900);
  cpID->Divide(2,4);
  cpID->cd(1); h2SHMS_AERO_HGC->Draw("Colz");
  cpID->cd(2); h2SHMSp_kaon_cut->Draw("Colz");
  cpID->cd(3); h2SHMS_CAL_HGC->Draw("Colz");
  cpID->cd(4); h2SHMSp_pion_cut->Draw("Colz");
  cpID->cd(5); h2ROC1_Coin_Beta_noID_proton->Draw("Colz");
  cpID->Update();
  TLine *pLowerRand = new TLine(6.0,gPad->GetUymin(),6.0,gPad->GetUymax()); 
  pLowerRand->SetLineColor(kRed); pLowerRand->SetLineWidth(1); pLowerRand->Draw();
  TLine *pUpperRand = new TLine(20.0,gPad->GetUymin(),20.0,gPad->GetUymax());  
  pUpperRand->SetLineColor(kRed); pUpperRand->SetLineWidth(1); pUpperRand->Draw();
  cpID->cd(6); h2ROC1_Coin_Beta_proton->Draw("Colz");
  cpID->cd(7); h1mmissp->Draw();
  cpID->cd(8); h1mmissp_remove->Draw("hist");
  cpID->Update();
  cpID->Print(outputpdf);  
  
  TCanvas *cCoinTime = new TCanvas("cCoinTime","Summary of coincidence time and random",400,150,1000,900);
  cCoinTime->Divide(2,2);
  cCoinTime->cd(1);
  h1mmisspi_cut->Draw();
  h1mmisspi_rand->Draw("same");
  h1mmisspi_rand->SetLineColor(2);
  cCoinTime->cd(2);
  h1mmisspi_rand->Draw();
  cCoinTime->cd(3);
  h1mmisspi_remove->Draw();
  cCoinTime->cd(4);
  h2misspicut_CT->Draw("Colz");
  cCoinTime->Print(outputpng_coin);
  cCoinTime->Print(outputpdf);
  
  //Start output of .root file with all histograms
  TFile *Histogram_file = new TFile(Form("../HISTOGRAMS/KaonLT_Proton_Run%i.root",option.Atoi()),"RECREATE");
  TDirectory *DCuts = Histogram_file->mkdir("Spectrometer Delta and Calorimeter Cuts"); DCuts->cd();
  h1HMS_delta->Write("HMS Delta Before Cuts"); h1HMS_delta_cut->Write("HMS Delta After Cuts");
  h1SHMS_delta->Write("SHMS Delta Before Cuts"); h1SHMS_delta_cut->Write("SHMS Delta After Cuts");
  HMS_electron->Write("HMS Calorimeter Before Cuts"); HMS_electron_cut->Write("HMS Calorimeter After Cuts");
  h1SHMS_electron->Write("SHMS Calorimeter Before Cuts"); h1SHMS_electron_cut->Write("SHMS Calorimeter After Cuts");
  h2SHMS_AERO_HGC->Write("SHMS Aerogel vs HGC before Cuts"); h2SHMS_CAL_HGC->Write("SHMS Calorimeter vs HGC Before Cuts");

  TDirectory *DAngles = Histogram_file->mkdir("Spectrometer Angular Cuts"); DAngles->cd();
  h1HMS_th->Write("HMS Theta Before Cuts"); h1HMS_th_cut->Write("HMS Theta After Cuts");
  h1SHMS_th->Write("SHMS Theta Before Cuts"); h1SHMS_th_cut->Write("SHMS Theta After Cuts");
  h1HMS_ph->Write("HMS Phi Before Cuts"); h1HMS_ph_cut->Write("HMS Phi After Cuts");
  h1SHMS_ph->Write("SHMS Phi Before Cuts"); h1SHMS_ph_cut->Write("SHMS Phi After Cuts");

  TDirectory *DRand = Histogram_file->mkdir("Random Subtraction Summary"); DRand->cd();
  h1mmissK_cut->Write("Kaon Missing Mass, with Randoms");
  h1mmissK_rand->Write("Kaon Missing Mass, only Randoms");
  h1mmissK_remove->Write("Kaon Missing Mass, Randoms Removed");

  h1mmisspi_cut->Write("Pion Missing Mass, with Randoms");
  h1mmisspi_rand->Write("Pion Missing Mass, only Randoms");
  h1mmisspi_remove->Write("Pion Missing Mass, Randoms Removed");
  h1mmissp_cut->Write("Proton Missing Mass, with Randoms");
  h1mmissp_rand->Write("Proton Missing Mass, only Randoms");
  h1mmissp_remove->Write("Proton Missing Mass, Randoms Removed");

  TDirectory *DKaon = Histogram_file->mkdir("Kaon Identification Summary"); DKaon->cd();
  h2SHMSK_kaon_cut->Write("SHMS HGC vs Aerogel, with cuts");
  h2SHMSK_pion_cut->Write("SHMS HGC vs CAL, with cuts");
  h2ROC1_Coin_Beta_noID_kaon->Write("Kaon-Electron Coincidence Time, no cuts");
  h2ROC1_Coin_Beta_kaon->Write("Kaon-Electron Coincidence Time, with cuts");
  h2missKcut_CT->Write("Kaon-Electron Coincidence Time vs Missing Mass");
  h1mmissK->Write("Kaon Missing Mass, no cuts");
  h1mmissK_remove->Write("Kaon Missing Mass, with cuts");

  TDirectory *DPion = Histogram_file->mkdir("Pion Identification Summary"); DPion->cd();
  h2SHMS_AERO_HGC->Write("SHMS HGC vs Aerogel no cuts"); 
  h2SHMSpi_kaon_cut->Write("SHMS HGC vs Aerogel, with cuts");
  h2SHMS_CAL_HGC->Write("SHMS HGC vs CAL, no Cuts");
  h2SHMSpi_pion_cut->Write("SHMS HGC vs CAL, with cuts");
  h2ROC1_Coin_Beta_noID_pion->Write("Pion-Electron Coincidence Time, no cuts");
  h2ROC1_Coin_Beta_pion->Write("Pion-Electron Coincidence Time, with cuts");
  h2misspicut_CT->Write("Pion-Electron Coincidence Time vs Missing Mass");
  h1mmisspi->Write("Pion Missing Mass, no cuts");
  h1mmisspi_remove->Write("Pion Missing Mass, with cuts");

  TDirectory *DProton = Histogram_file->mkdir("Proton Identification Summary"); DProton->cd();
  h2SHMS_AERO_HGC->Write("SHMS HGC vs Aerogel no cuts");
  h2SHMSp_kaon_cut->Write("SHMS HGC vs Aerogel, with cuts");
  h2SHMS_CAL_HGC->Write("SHMS HGC vs CAL no Cuts");
  h2SHMSp_pion_cut->Write("SHMS HGC vs CAL, with cuts");
  h2ROC1_Coin_Beta_noID_proton->Write("Proton-Electron Coincidence Time, no cuts");
  h2ROC1_Coin_Beta_proton->Write("Proton-Electron Coincidence Time, with cuts");
  h1mmissp->Write("Proton Missing Mass, no cuts");
  h1mmissp_remove->Write("Proton Missing Mass, with cuts");

  TDirectory *DKine = Histogram_file->mkdir("Higher Order Kinematics Summary"); DKine->cd();
  h2WvsQ2->Write("W vs Q2");
  h2tvsph_q->Write("t vs phi");
  h1epsilon->Write("epsilon");
  h1mmisspi_remove->Write("Pion Missing Mass, with cuts");

  TDirectory *DEDTM = Histogram_file->mkdir("Accepted EDTM Events"); DEDTM->cd();
  EDTM->Write("EDTM TDC Time");
  Histogram_file->Close();
  
}
