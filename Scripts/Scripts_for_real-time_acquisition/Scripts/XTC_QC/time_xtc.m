
numOfScans=10;
xtcDir='C:\xtc_output\0005';

config_display( 0, 1, [0 0 0], [1 1 1], 'Arial', 25, 15 )
config_sound(2,16,44100,30); config_keyboard; 

start_cogent;

copyfile('Start.txt', 'C:\xtc_output\ScannerUpdates\Start.txt');
startTime=time
for volume=1:numOfScans % start with a lower number, e.g. 10 scans
    % wait for pulse DEPENDS ON THE KIND OF PULSES RECEIVED, e.g. the letter "S"
    waitkeydown(inf,20) % comment out if you are not using scanner pulses
    pulseTime(volume)=time
    % wait for filestt
    while   ~exist([xtcDir '/Dump-' sprintf('%04d',(volume-1)) '.par'],'file')...
            || ~exist([xtcDir '/Dump-' sprintf('%04d',(volume-1)) '.rec'],'file'); 
    end
    parTime(volume)=time
%     % convert to nii
%     xtc2nii(xtcDir, 'D:\NPAD\XTC2NII_test', template_hdr_file)  
%     % report time
    Time(volume)=time-startTime
end

% display interScan times
display(['scan ' num2str(scanNum) ' is available as nii ' num2str(Time(numOfScan)) ' seconds after start' ...
    ' and ' num2str(Time(numOfScan)-Time(numOfScan-1)) ' after the previous scan.']);      
for scanNum=2:numOfScans; InterScanTimes(numOfScan)=Time(numOfScan)-Time(numOfScan-1); end
mean_interscan_interval=mean(InterScanTimes)
median_interscan_interval=median(InterScanTimes)
min_interscan_interval=min(InterScanTimes)
max_interscan_interval=max(InterScanTimes)


% 
% 
% pulseTime =
% 
%   Columns 1 through 11
% 
%        26016       49756       61626       73496       85366       97236      109106      120976      132846      144716      156586
% 
%   Columns 12 through 20
% 
%       168456      180326      192196      204066      215936      227806      239676      251546      305796
% 
% 
% parTime =
% 
%   Columns 1 through 11
% 
%        40819       49757       61627       73497       85368       97237      109107      120977      132847      144717      156587
% 
%   Columns 12 through 20
% 
%       168459      180327      192197      204067      215937      227807      239677      251547      305798
%       
%       
%       
%       
%       
%       