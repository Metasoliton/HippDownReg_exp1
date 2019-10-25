%%% MANUAL STEP: ENABLE THE NETWORK CONNECTION TO THE NAS

function step1_prepare_folders(ExpCode, SubCode)


%  check/create folder structure on NETWORK & on DATA_DRIVE
    % folders to export to from scanner
if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode])~=7;
    mkdir(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode]); 
end
if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode])~=7;
    mkdir(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode]); 
end
if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/T1'])~=7;
    mkdir(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/T1']); 
end
if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer'])~=7;
    mkdir(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/realtime_localizer']); 
end
if exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/rev_realtime_localizer'])~=7;
    mkdir(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/' ExpCode '/' SubCode '/rev_realtime_localizer']); 
end


% folders to save data
if exist(['D:\NPAD\' ExpCode])~=7;
    mkdir(['D:\NPAD\' ExpCode]); 
end

if exist(['D:\NPAD\' ExpCode '/DATA/' SubCode])~=7;
    mkdir(['D:\NPAD\' ExpCode '/DATA/' SubCode]); 
end
if exist(['D:\NPAD\' ExpCode '/DATA/' SubCode '/T1'])~=7;
    mkdir(['D:\NPAD\' ExpCode '/DATA/' SubCode '/T1']); 
end
if exist(['D:\NPAD\' ExpCode '/DATA/' SubCode '/realtime_localizer'])~=7;
    mkdir(['D:\NPAD\' ExpCode '/DATA/' SubCode '/realtime_localizer']); 
end
if exist(['D:\NPAD\' ExpCode '/DATA/' SubCode '/rev_realtime_localizer'])~=7;
    mkdir(['D:\NPAD\' ExpCode '/DATA/' SubCode '/rev_realtime_localizer']); 
end







