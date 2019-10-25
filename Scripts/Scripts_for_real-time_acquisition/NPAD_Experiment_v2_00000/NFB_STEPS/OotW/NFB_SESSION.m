% MY INSTRUCTIONS

%8:00-8:30 % setup STIM_A with correct IP
%8:20-8:30 % setup Pilot2_NFB

% duplicate NPAD_Experiment_v?_sub?
% cd NPAD_Experiment_v?_sub?
% addpath NPAD_Experiment_v?_sub? (remove previous if necessary)
delete ./LocalizerData/*
delete ./sMRI/*
delete ./realtime/*
delete ./ROIs/WFU_PickAtlas/r*
delete ./ROIs/WFU_PickAtlas/w*

% delete c:/xtc_output/00*  % best do this manually...
% if exist c:/xtc_output/00* move it somewhere safe so that there are no
% c:/xtc_output/00* folders present

global ExpCode SubCode % also used in RETIF>Classifiers>RT_Classifier_NPAD
ExpCode='Pilot_2_NFB';
SubCode=input('Please enter subject name ; e.g. SUB000 . ' , 's')

nLocalizerVolumes=10; 
nSlices=45;

%step 0: %%% MANUAL STEP: CHECK/ENABLE THE NETWORK CONNECTION TO THE NAS
% e.g. paste into a windows explorer: \\NI_DATA\Projects\MRI_Console\MRI_2_Stavros

step1_prepare_folders(ExpCode, SubCode)

%step2 %%% MANUAL STEP: scan T1 and copy dicoms to ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/T1']

% step4: get T1 from NAS
dicm2nii(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/T1']', ['D:\NPAD\' ExpCode '/DATA/' SubCode '/T1'],4);

% Set origin and reorient T1 manually
base=pwd; cd(['../DATA/' SubCode '/T1/']);
set(0, 'DefaultFigureVisible', 'on'); 
spm fmri;
cd(base);

step6_segmentT1 %.m

%step 3 NOW start scanning 10 rt volumes (identical sequence) for header & localizer in folder xtc_output/0000
% and then copy offline dicoms to ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer']

% MANUAL ACTION: Start CMD CorbaDataDumper
% cd c:\xtc
% CorbaDataDumper.exe 10.60.11.20 10.60.11.150 c:\xtc_output
% % % (IPv4 Gateway 10.60.11.245)

cd(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode])
copyfile('C:\xtc\Start.txt', 'C:\xtc_output\ScannerUpdates\Start.txt');
% MANUAL ACTION: Transfer dicoms to ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/

% step5: get EPI from NAS, perform QC and extract template header
% rt_QC(xtcDir,dcmDir,niixDir,ExpCode,nVolumes,nSlices)
template_hdr_file=step5_rt_QC('C:\xtc_output\0000',['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer'], ['D:\NPAD\' ExpCode '/DATA/' SubCode '/realtime_localizer/'], ExpCode, SubCode,nLocalizerVolumes, nSlices); %% <<< 45!?
%%%% IF DCM2NIIX GIVES A ROUNDING WARNING, USE SPM IMPORT INSTEAD

% step 7:  xtc2nii from xtc_output/0000 to ./LocalizerData/
for volume=1:10; xtc2nii('C:\xtc_output\0000', './LocalizerData/', template_hdr_file, ExpCode,volume,nSlices); end 

%% %% %% %% %% %% %% 
step8_coregROI %.m
%step9
save(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\NFB_STEPS/ready.mat'])

%% %% %% %% %% %% %% 
%step10: start RETIF
%% adapt if necessary
scratch;clear all;clear classes;clc;

global robot; robot=0;

load('experiment_NPAD_v2.mat')                                           
    % template/reference file for movement correction
    flist=ls('.\LocalizerData\'); templfile=['.\LocalizerData\' flist(3,:)]; 
    % these files and variables must correspond to each other
    prefeedbackinstrfile='instructions_prefeedback.txt';
    feedbackinstrfile='instructions_feedback.txt';
    nrprefeedback=40;% set number of volumes in preffedd and feedback HERE
    nrfeedback=420; 
    % this determines how neurofeedback is computed
    classify.type='RT_Classifier_NPADv2';
save('experiment_NPAD_v2.mat')                                           
GUI=RETIF
movegui(GUI.figmain,'north')
%% %% %% %% %% %% %% 
%% %% %% %% %% %% %% 
%% %% %% %% %% %% %% 

% MANUAL ACTION: Open Matlab 2015 
% ON THE 2nd MATLAB COMMANDLINE !!!
 
% step10: load variables from 1st MATLAb COMMANDLINE
cd to subject folder\NFB_STEPS

load(['ready.mat'])
%%% START CMD CorbaDataDumper

start_scanner_XTC2NII % no wait delay or with wait delay for simulation 


%%% AFTER THE END OF SCANNING
cd NFB_STEPS; load('ready.mat');
global BSL NF_signal NFB_signal robot
save('done_v1.mat','BSL','NFB_signal','NF_signal','robot')
mkdir(['C:\xtc_output\' ExpCode '_' SubCode]);

cp 000 0001 new folder










