% MY INSTRUCTIONS

% duplicate NPAD_Experiment_v?_sub?
% cd NPAD_Experiment_v?_sub?

% prepare files
copyfile(['G:\NPAD\sub-' SubCode '\anat\sub-' SubCode '_T1w_N4_mabonlm.nii'],['.\ROIs\JLF\sub-' SubCode '_T1w_N4_mabonlm.nii']
copyfile(['G:\NPAD\sub-' SubCode '\anat\JLF\sub-_left_CA1.nii'],['.\ROIs\JLF\sub-_left_CA1.nii']);
copyfile(['G:\NPAD\sub-' SubCode '\anat\JLF\sub-_right_CA1.nii'],['.\ROIs\JLF\sub-_right_CA1.nii']);
spm_check_registration

%%

delete ./LocalizerData/*
delete ./sMRI/*
delete ./realtimedata/*
delete ./ROIs/WFU_PickAtlas/r*
delete ./ROIs/WFU_PickAtlas/w*

addpath(genpath('./'));

% delete c:/xtc_output/00*  % best do this manually...
% if exist c:/xtc_output/00* move it somewhere safe so that there are no
% c:/xtc_output/00* folders present

nLocalizerVolumes=10; 
nSlices=45;

global ExpCode SubCode % also used in RETIF>Classifiers>RT_Classifier_NPAD
ExpCode='NPAD'; % or NPAD
SubCode=input('Please enter subject name ; e.g. SUB000 . ' , 's')



%step 0: %%% MANUAL STEP: CHECK/ENABLE THE NETWORK CONNECTION TO THE NAS
% e.g. paste into a windows explorer: \\NI_DATA\Projects\MRI_Console\MRI_2_Stavros

step1_prepare_folders(ExpCode, SubCode)

%%

%step 3 NOW start scanning 10 rt volumes (identical sequence) for reverse localizer in folder xtc_output/0001 and then copy offline dicoms to ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer']
% MANUAL ACTION: click on connectScanner.bat OR...
% OR % cd c:\xtc % CorbaDataDumper.exe 10.60.11.20 10.60.11.150 c:\xtc_output % % % (IPv4 Gateway 10.60.11.245)
command=['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\connectScanner.bat &']; system(command);
display('PRESS ANY BUTTON TO START SCANNING'); pause;

cd(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode])
copyfile('C:\xtc\Start.txt', 'C:\xtc_output\ScannerUpdates\Start.txt');

% MANUAL ACTION: Export dicoms to console and NAS

while 1==1
    if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/rev_realtime_localizer/DICOM/IM_0450'],'file')==0; pause(1); 
    else
        break
    end
end


dcmDir=['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/rev_realtime_localizer']; 
niixDir=['D:\NPAD\' ExpCode '\DATA\' SubCode '\rev_realtime_localizer\'];
pwDir=pwd; cd D:\NPAD\Resources\Software\MRIcroGL\mricrogl
command = ['dcm2niix -o ' [niixDir] ' ' dcmDir] ; system(command); cd(pwDir);
fnii4D=ls([niixDir '\*.nii']); flist = spm_file_split([niixDir '\' fnii4D(1,:)]); 


%%
%step 3 NOW start scanning 10 rt volumes (identical sequence) for header & localizer in folder xtc_output/0001 and then copy offline dicoms to ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer']
% MANUAL ACTION: click on connectScanner.bat OR...
command=['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\connectScanner.bat &']; system(command);
display('PRESS ANY BUTTON TO START SCANNING'); pause;

cd(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode])
copyfile('C:\xtc\Start.txt', 'C:\xtc_output\ScannerUpdates\Start.txt');

% MANUAL ACTION: Export dicoms to console and NAS

while 1==1
    if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer/DICOM/IM_0450'],'file')==0; pause(1); 
    else
        break
    end
end

% step5: get EPI from NAS, perform QC and extract template header
% %%%INTRODUCE WAIT FOR LAST EXPECTED DICOM
template_hdr_file=step5_rt_QC('C:\xtc_output\0001',['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer'], ['D:\NPAD\' ExpCode '/DATA/' SubCode '/realtime_localizer/'], ExpCode, SubCode,nLocalizerVolumes, nSlices); %% <<< 45!?
%%%% IF DCM2NIIX GIVES A ROUNDING WARNING, USE SPM IMPORT INSTEAD

% step 7:  xtc2nii from xtc_output/0000 to ./LocalizerData/
for volume=1:10; xtc2nii('C:\xtc_output\0001', './LocalizerData/', template_hdr_file, ExpCode,volume,nSlices); end 

step15_prepare_ROI_mask
save(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\NFB_STEPS/ready.mat'])
spm_check_registration([ref_data '/' flist(12).name  ',1'], [ROI_dir '/rsub-' SubCode '_T1w_N4_mabonlm_brain.nii,1'], ['.\ROIs\JLF\CA1_mask.nii,1'])


%% %% %% %% %% %% %% 
%step10: start RETIF
%% adapt if necessary
scratch;clear all;clear classes;clc;
global robot; robot=0;
    load('experiment_NPAD_v2.mat')                                           
    % template/reference file for movement correction
    flist=ls('.\LocalizerData\'); templfile=['.\LocalizerData\' flist(12,:)]; 
    % these files and variables must correspond to each other
    prefeedbackinstrfile='instructions_prefeedback.txt';
    feedbackinstrfile='instructions_feedback.txt';
    nrprefeedback=40;% set number of volumes in preffedd and feedback HERE
    nrfeedback=570; 
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
command=['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\connectScanner.bat &']; system(command);
display('PRESS ANY BUTTON TO START SCANNING'); pause;

copyfile(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\NFB_STEPS\utilities\NF_signal1.txt'], ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/NF_signal.txt']);
pause(1);
copyfile(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\NFB_STEPS\utilities\NF_signal2.txt'], ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/NF_signal.txt']);
start_scanner_XTC2NII % no wait delay or with wait delay for simulation 
%% %% %% %% %% %% %% 
%% %% %% %% %% %% %% 
%% %% %% %% %% %% %% 
%%

%%% AFTER THE END OF SCANNING
% cd NFB_STEPS; load('ready.mat');
% global BSL NF_signal NFB_signal robot

load NFB_steps/ready.mat
save('done_v2.mat') %,'BSL','NFB_signal','NF_signal','robot')
mkdir(['C:\xtc_output\' ExpCode '_' SubCode]);
movefile(['C:\xtc_output\0000'],['C:\xtc_output\' ExpCode '_' SubCode]);
movefile(['C:\xtc_output\0001'],['C:\xtc_output\' ExpCode '_' SubCode]);
movefile(['C:\xtc_output\0002'],['C:\xtc_output\' ExpCode '_' SubCode]);

%%








