copyfile('C:\xtc\Start.txt', 'C:\xtc_output\ScannerUpdates\Start.txt');

startTime=time

% step 11: ON THE 2nd MATLAB COMMANDLINE
% convert realtime data to nii
xtcDir='C:\xtc_output\0002'
volume=1;
while 1==1
    if exist([xtcDir '/Dump-' sprintf('%04d',(volume-1)) '.par'],'file') ...
    && exist([xtcDir '/Dump-' sprintf('%04d',(volume-1)) '.rec'],'file') ... 
    && exist(['./realtimedata\Volume' sprintf('%03d',volume) '.nii'],'file')==0;
     xtc2nii(xtcDir, '../realtimedata', template_hdr_file, ExpCode,volume,nSlices);
%       wait(3000)
    volume=volume+1;

    end
end
