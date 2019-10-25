%%% AFTER THE END OF SCANNING
% cd NFB_STEPS; load('ready.mat');
% global BSL NF_signal NFB_signal robot

load NFB_steps/ready.mat
save('done_v2.mat') %,'BSL','NFB_signal','NF_signal','robot')
mkdir(['C:\xtc_output\' ExpCode '_' SubCode]);
movefile(['C:\xtc_output\0000'],['C:\xtc_output\' ExpCode '_' SubCode]);
movefile(['C:\xtc_output\0001'],['C:\xtc_output\' ExpCode '_' SubCode]);
movefile(['C:\xtc_output\0002'],['C:\xtc_output\' ExpCode '_' SubCode]);
