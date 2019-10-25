%% Raw signal

clear;clc;

base=pwd; cd ./ROIs/JLF; ROI_dir=pwd; cd(base);
ROI = [ROI_dir '/CA1_mask.nii,1']; % resliced to fMRI space
flist=ls('.\realtimedata\*.nii')
 
for vol=1:length(flist); 
    % load data
    data=spm_summarise(['.\realtimedata\' flist(vol,:)],ROI);
    DATA(:,vol)=reshape(data,[],1);
end 

MEAN=mean(DATA);
MODE=mode(DATA);
MEDIAN=median(DATA);
figure; plot(MEAN,'r'); hold on; plot(MEDIAN,'b'); hold off; 

%% Filtered with 128Hz High-pass 
K.RT = 3;
K.row = 1:length(MEAN); % 130 corresponds to the length of convreg
K.HParam = 128; % cut-off period in seconds
filt_MEAN = spm_filter(spm_filter(K), MEAN');
filt_MEDIAN = spm_filter(spm_filter(K), MEDIAN');
figure; plot(filt_MEAN,'r'); hold on; plot(filt_MEDIAN,'b'); hold off; 


%% Normalized by WM
WM = [ROI_dir '/rp2sub-' SubCode '_T1w_N4_mabonlm_bin.nii,1']; % resliced to fMRI space
for vol=1:length(flist); 
    wm_data=spm_summarise(['.\realtimedata\' flist(vol,:)],WM);
    WM_DATA(:,vol)=reshape(wm_data,[],1);
end 

WM_mean=mean(WM_DATA);
norm_MEAN=mean(DATA) ./ WM_mean ;
norm_MEDIAN=median(DATA) ./ WM_mean ;
figure; plot(norm_MEAN,'r'); hold on; plot(norm_MEDIAN,'b'); hold off; 

spm_check_registration(ROI,WM,['.\LocalizerData\Volume010.nii']);


%% detrendDATA = RT_detrend_SP(DATA(:,1:end), 0, 200);
    lambda=200;
    data = double(DATA)';
    T = size(data,1);  
    I = speye(T);
    D2 = spdiags(ones(T-2,1)*[1 -2 1],[0:2],T-2,T);
    datadt = (I-inv(I+lambda^2*(D2'*D2)))*data;
 %   datadt = datadt(end,:) + data(1,:);
    dt_MEAN=mean(datadt');
    dt_MEDIAN=mode(datadt');
figure; plot(dt_MEAN,'r'); hold on; plot(dt_MEDIAN,'b'); hold off; 

    
    
    