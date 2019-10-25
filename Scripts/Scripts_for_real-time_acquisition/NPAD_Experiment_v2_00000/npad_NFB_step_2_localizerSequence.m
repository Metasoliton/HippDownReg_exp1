%% STEP 2    npad_NFB_step_2
%step 3 NOW start scanning 10 rt volumes (identical sequence) for header & localizer in folder xtc_output/0001 and then copy offline dicoms to ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer']
% MANUAL ACTION: click on connectScanner.bat OR...
command=['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\connectScanner.bat &']; system(command);
display(''); display(''); display('# # # WAIT FOR SCANNER TO CONNECT... # # #');
display(''); display(''); display('# # # THEN START THE ACQUISITION FROM THE CONSOLE. # # #'); 
display(''); display(''); display('# # # WHEN THE SCANNER IS READY (BEEP), PRESS ANY BUTTON INSIDE THIS MATLAB WINDOW TO START SCANNING. # # #'); pause;

cd(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode])
copyfile('C:\xtc\Start.txt', 'C:\xtc_output\ScannerUpdates\Start.txt');

% MANUAL ACTION: Export dicoms to console and NAS
display(''); display(''); display('# # # WHEN SCANNING COMPLETES, PLEASE EXPORT DICOMS FROM LOCALIZER SEQUENCE # # #'); 


while 1==1
    if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer/DICOM/IM_0450'],'file')==0; pause(1); 
    else
        break
    end
end

display(''); display(''); display('# # # PLEASE WAIT # # #');

% step5: get EPI from NAS, perform QC and extract template header
% %%%INTRODUCE WAIT FOR LAST EXPECTED DICOM
template_hdr_file=step5_rt_QC('C:\xtc_output\0001',['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer'], ['D:\NPAD\' ExpCode '/DATA/' SubCode '/realtime_localizer/'], ExpCode, SubCode,nLocalizerVolumes, nSlices); %% <<< 45!?
%%%% IF DCM2NIIX GIVES A ROUNDING WARNING, USE SPM IMPORT INSTEAD

% step 7:  xtc2nii from xtc_output/0000 to ./LocalizerData/
for volume=1:10; xtc2nii('C:\xtc_output\0001', './LocalizerData/', template_hdr_file, ExpCode,volume,nSlices); end 

step15_prepare_ROI_mask
save(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\NFB_STEPS/ready.mat'])
spm_check_registration([ref_data '/' flist(12).name  ',1'], [ROI_dir '/rsub-' SubCode '_T1w_N4_mabonlm_brain.nii,1'], ['.\ROIs\JLF\CA1_mask.nii,1'])

display(''); display(''); display('# # # PRESS ANY BUTTON TO CONTINUE # # #')
pause


%% 
% adapt if necessary
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

display(''); display(''); display('# # # PLEASE CLOSE MS-DOS TERMINAL!!! # # #')
display(''); display(''); display('# # # THEN, LOAD EXPERIMENT IN GUI, PRESS START AND RUN STEP 3 IN A NEW MATLAB WINDOW # # #')
