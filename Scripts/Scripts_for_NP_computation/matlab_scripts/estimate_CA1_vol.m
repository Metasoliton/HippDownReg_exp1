SUBs=[]; % enter participant IDs here


for s=1:length(SUBs)

    SUBs(s)
    
    data=['../../Data/NPAD/sub-' num2str(SUBs(s)) '/func/rasub-' num2str(SUBs(s)) '_NFB.nii,1'];

    CA1=['../../Data/NPAD/sub-' num2str(SUBs(s)) '/anat/postNFB/sub-' num2str(SUBs(s)) '_CA1.nii'];
    TS_CA1=(spm_summarise(data,CA1))';
    
    [CA1_vol(s) ~]=size(TS_CA1); % estimate CA1 volume from ROI size
    
end


CA1_vol