%% STEP 3
% MANUAL ACTION: Open Matlab 2015 
% ON THE 2nd MATLAB COMMANDLINE !!!
 
% step10: load variables from 1st MATLAb COMMANDLINE
cd NFB_STEPS

load(['ready.mat'])
%%% START CMD CorbaDataDumper
command=['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\connectScanner.bat &']; system(command);
display(''); display(''); display('# # # WAIT FOR SCANNER TO CONNECT... # # #');
display(''); display(''); display('# # # THEN START THE ACQUISITION FROM THE CONSOLE. # # #'); 
display(''); display(''); display('# # # WHEN THE SCANNER IS READY (BEEP), PRESS ANY BUTTON INSIDE THIS MATLAB WINDOW TO START SCANNING. # # #'); pause;

copyfile(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\NFB_STEPS\utilities\NF_signal1.txt'], ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/NF_signal.txt']);
pause(1);
copyfile(['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\NFB_STEPS\utilities\NF_signal2.txt'], ['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/NF_signal.txt']);
start_scanner_XTC2NII % no wait delay or with wait delay for simulation 
%% %% %% %% %% %% %% 