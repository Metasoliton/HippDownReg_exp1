%% STEP 1 npad_NFB_step_1

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

%2BCUSTOM%%% MANUAL STEP: CHECK/ENABLE THE NETWORK CONNECTION TO THE NAS
% e.g. paste into a windows explorer: \\NI_DATA\Projects\MRI_Console\MRI_2_Stavros
% Project folder must exist!
% e.g. [\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/]

step1_prepare_folders(ExpCode, SubCode)

%% 

%step 3 NOW start scanning 10 rt volumes (identical sequence) for reverse localizer in folder xtc_output/0001 and then copy offline dicoms to ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer']
% MANUAL ACTION: click on connectScanner.bat OR...
% OR % cd c:\xtc % CorbaDataDumper.exe 10.60.11.20 10.60.11.150 c:\xtc_output % % % (IPv4 Gateway 10.60.11.245)
command=['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\connectScanner.bat &']; system(command);
display(''); display(''); display('# # # WAIT FOR SCANNER TO CONNECT... # # #');
display(''); display(''); display('# # # THEN START THE ACQUISITION FROM THE CONSOLE. # # #'); 
display(''); display(''); display('# # # WHEN THE SCANNER IS READY (BEEP), PRESS ANY BUTTON INSIDE THIS MATLAB WINDOW TO START SCANNING. # # #'); pause;

cd(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode])
copyfile('C:\xtc\Start.txt', 'C:\xtc_output\ScannerUpdates\Start.txt');

% MANUAL ACTION: Export dicoms to console and NAS
display(''); display(''); display('# # # WHEN SCANNING COMPLETES, PLEASE EXPORT DICOMS FROM REVERSE SEQUENCE # # #'); 


while 1==1
    if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/rev_realtime_localizer/DICOM/IM_0450'],'file')==0; pause(1); 
    else
        break
    end
end

display(''); display(''); display('# # # PLEASE WAIT # # #');


dcmDir=['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/rev_realtime_localizer']; 
niixDir=['D:\NPAD\' ExpCode '\DATA\' SubCode '\rev_realtime_localizer\'];
pwDir=pwd; cd D:\NPAD\Resources\Software\MRIcroGL\mricrogl
command = ['dcm2niix -o ' [niixDir] ' ' dcmDir] ; system(command); cd(pwDir);
fnii4D=ls([niixDir '\*.nii']); flist = spm_file_split([niixDir '\' fnii4D(1,:)]); 

display(''); display(''); display('# # # PLEASE CLOSE MS-DOS TERMINAL!!! # # #')
display(''); display(''); display('# # # THEN, RUN npad_NFB_step_2 # # #')

