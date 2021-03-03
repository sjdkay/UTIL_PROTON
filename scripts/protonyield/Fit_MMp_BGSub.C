// 08/09/20 - Stephen Kay, University of Regina

// root .c macro fitting script
#define Fit_MMp_BGSub_cxx

// Include relevant stuff
#include <TStyle.h>
#include <TCanvas.h>
#include <TLine.h>
#include <TMath.h>
#include <TPaveText.h>
#include <TGaxis.h>
#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include <TSystem.h>
#include <TTree.h>
#include <TArc.h>

// Input should be the input root file name (including suffix) and an output file name string (without any suffix)
//void PlotProtonPhysics_NoRFCut(string InFilename = "", string OutFilename = "")
void Fit_MMp_BGSub(string InFilename = "", string OutFilename = "")
{
  TString Hostname = gSystem->HostName();
  TString User = (gSystem->GetUserInfo())->fUser;
  TString Replaypath;
  TString Outpath;
  TString rootFile;
  Double_t nWindows = 6;
  gStyle->SetPalette(55);

  // Set paths depending on system you're running on
  if(Hostname.Contains("farm")){
    //Replaypath = "/group/c-pionlt/USERS/"+User+"/hallc_replay_lt";
    Outpath = Replaypath+"/UTIL_PROTON/OUTPUT/Analysis/ProtonLT";
  }
  else if(Hostname.Contains("qcd")){
    //Replaypath = "/group/c-pionlt/USERS/"+User+"/hallc_replay_lt";
    Outpath = Replaypath+"/UTIL_PROTON/OUTPUT/Analysis/ProtonLT";
  }
  else if (Hostname.Contains("phys.uregina.ca")){
    //Replaypath = "/home/"+User+"/work/JLab/hallc_replay_lt";
    Outpath = Replaypath+"/UTIL_PROTON/OUTPUT/Analysis/ProtonLT";
  }
  // Add more as needed for your own envrionment
  else{
    //Replaypath="/ExtDsk/sjdkay/JLab/Proton_Analysis/OUTPUT/Pass2_3";
    Outpath = "/home/sjdkay/Work/JLab/UTIL_PROTON/OUTPUT/Analysis/ProtonLT";
  }

  if(InFilename == "") {
    cout << "Enter a Filename to analyse: ";
    cin >> InFilename;
  }  
  if(OutFilename == "") {
    cout << "Enter a Filename to output to: ";
    cin >> OutFilename;
  }
  TString TInFilename = InFilename;
  rootFile = Outpath+"/"+TInFilename;
  // Complain and exit if your file doesn't exist
  if (gSystem->AccessPathName(rootFile) == kTRUE){
    cerr << "!!!!! ERROR !!!!! " << endl << rootFile <<  " not found" << endl <<  "!!!!! ERRROR !!!!!" << endl;
    exit;
  }
  TFile *InFile = new TFile(rootFile, "READ");
  // This assumes a 4 digit run number! Should work for now, saves it as an additional input
  // This ALSO assumes the Filename is XXXX_..... too, which may not be true, edit as needed
  TString TOutFilename = OutFilename;
  // Establish the names of our output files quickly
  TString foutname = Outpath + "/" + TOutFilename + ".root";
  TString foutpdf = Outpath + "/" + TOutFilename + ".pdf";
  InFile->cd("Proton kinematics info");
  TDirectory *ProtonKinDir = (TDirectory*)InFile->Get("Proton kinematics info");
  
  TH1D *MMpBGSub=(TH1D*)ProtonKinDir->Get("h1_MMp_BGSub");

  // Fit the Proton MM plot
  // Grab MaxBinVal to set amplitude limits
  Double_t MaxBinVal = MMpBGSub->GetBinContent(MMpBGSub->GetMaximumBin());
  // Function is two Gaussians + a linear component for the background
  TF1 *LinBG = new TF1("LinBG", "([0]*x)+[1]", 0.5, 1.3);
  LinBG->SetParName(0, "LinBG_Slope");
  LinBG->SetParName(1, "LinBG_Intercept");
  MMpBGSub->Fit("LinBG", "RM");
  
  TF1 *ProtonFitSingle = new TF1("ProtonFitSingle","([0]*exp(-0.5*((x-[1])/[2])*((x-[1])/[2])))+(([3]*x)+[4])",0.5,1.1);
   ProtonFitSingle->SetParName(0,"Amplitude_Omega");
   ProtonFitSingle->SetParName(1,"Mean_Omega");
   ProtonFitSingle->SetParName(2,"Sigma_Omega");
   ProtonFitSingle->SetParName(3, "Lin_Slope");
   ProtonFitSingle->SetParName(4, "Lin_Intercept");
   ProtonFitSingle->SetParLimits(0, (MaxBinVal/4), (MaxBinVal*1.5));
   ProtonFitSingle->SetParLimits(1,0.775,0.9);
   ProtonFitSingle->SetParameter(1, 0.782);
   ProtonFitSingle->SetParLimits(2, 0.01, 0.025);
   ProtonFitSingle->SetParameter(2, 0.02);
   ProtonFitSingle->FixParameter(3, (LinBG->GetParameter(0)));
   ProtonFitSingle->FixParameter(4, (LinBG->GetParameter(1)));
   MMpBGSub->Fit("ProtonFitSingle","RM");
   TF1 *OmegaFitSingle = new TF1("OmegaFitSingle", "([0]*exp(-0.5*((x-[1])/[2])*((x-[1])/[2])))", 0.7, 1.0);
   OmegaFitSingle->SetParameter(0, ProtonFitSingle->GetParameter(0));
   OmegaFitSingle->SetParameter(1, ProtonFitSingle->GetParameter(1));
   OmegaFitSingle->SetParameter(2, ProtonFitSingle->GetParameter(2));
   OmegaFitSingle->SetLineColor(1);
   
  TF1 *ProtonFit = new TF1("ProtonFit","([0]*exp(-0.5*((x-[1])/[2])*((x-[1])/[2])))+([3]*exp(-0.5*((x-[4])/[5])*((x-[4])/[5])))+(([6]*x)+[7])",0.5,1.2);
   ProtonFit->SetParName(0,"Amplitude_Omega");
   ProtonFit->SetParName(1,"Mean_Omega");
   ProtonFit->SetParName(2,"Sigma_Omega");
   ProtonFit->SetParName(3,"Amplitude_Phi");
   ProtonFit->SetParName(4,"Mean_Phi");
   ProtonFit->SetParName(5,"Sigma_Phi");
   ProtonFit->SetParName(6, "Lin_Slope");
   ProtonFit->SetParName(7, "Lin_Intercept");
   ProtonFit->SetParLimits(0, (MaxBinVal/4), (MaxBinVal*1.5));
   ProtonFit->SetParLimits(1,0.775,0.9);
   ProtonFit->SetParameter(1, 0.782);
   ProtonFit->SetParLimits(2, 0.01, 0.015);
   ProtonFit->SetParameter(2, 0.02);
   ProtonFit->SetParLimits(3, (MaxBinVal/4), (MaxBinVal*1.5));
   ProtonFit->SetParLimits(4, 1.05, 1.15);
   ProtonFit->SetParameter(4, 1.05);
   ProtonFit->SetParLimits(5, 0.01, 0.015);
   ProtonFit->SetParameter(5, 0.015);
   ProtonFit->FixParameter(6, (LinBG->GetParameter(0)));
   ProtonFit->FixParameter(7, (LinBG->GetParameter(1)));
   MMpBGSub->Fit("ProtonFit","RM");
   TF1 *OmegaFit = new TF1("OmegaFit", "([0]*exp(-0.5*((x-[1])/[2])*((x-[1])/[2])))", 0.7, 1.0);
   OmegaFit->SetParameter(0, ProtonFit->GetParameter(0));
   OmegaFit->SetParameter(1, ProtonFit->GetParameter(1));
   OmegaFit->SetParameter(2, ProtonFit->GetParameter(2));
   TF1 *PhiFit = new TF1("PhiFit", "([0]*exp(-0.5*((x-[1])/[2])*((x-[1])/[2])))", 0.9, 1.4);
   PhiFit->SetParameter(0, ProtonFit->GetParameter(3));
   PhiFit->SetParameter(1, ProtonFit->GetParameter(4));
   PhiFit->SetParameter(2, ProtonFit->GetParameter(5));
   OmegaFit->SetLineColor(1);
   PhiFit->SetLineColor(4);

   TCanvas *c_FitCanvas1 = new TCanvas("c_FitCanvas1", "Omega Fit", 100, 0, 1000, 900);
   c_FitCanvas1->cd();
   MMpBGSub->Draw("HIST");
   ProtonFitSingle->Draw("SAME");
   OmegaFitSingle->Draw("SAME");   
   c_FitCanvas1->Print(foutpdf + '(');

   TCanvas *c_FitCanvas2 = new TCanvas("c_FitCanvas2", "Double Fit", 100, 0, 1000, 900);
   c_FitCanvas2->cd();
   MMpBGSub->Draw("HIST");
   ProtonFit->Draw("SAME");
   OmegaFit->Draw("SAME");
   PhiFit->Draw("SAME");
   c_FitCanvas2->Print(foutpdf + ')');

   TFile *OutHistoFile = new TFile(foutname, "RECREATE");
   MMpBGSub->Write();
   ProtonFitSingle->Write();
   OmegaFitSingle->Write();
   ProtonFit->Write();
   OmegaFit->Write();
   PhiFit->Write();

   OutHistoFile->Close();
   
}
