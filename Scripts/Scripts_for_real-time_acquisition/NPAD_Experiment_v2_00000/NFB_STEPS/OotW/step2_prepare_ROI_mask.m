function ROI_mask = step2_prepare_ROI_mask(JLF_ROI_file)

global ExpCode SubCode 

ROI = JLF_ROI_file;

ROI_indices=spm_summarise(ROI,'all',@find)'; % gives indices
ROI_weights=spm_summarise(ROI,ROI)';         % gives values

[W,I] = sort(ROI_weights);
W_MLV = W(end-round(end/20) : end)'; % weights in top 5% most likely voxels
I_MLV = I(end-round(end/20) : end)'; % indices of top 5% most likely voxels

minThreshVal=min(W_MLV);

ROI_vol = spm_vol(ROI);  
ROI_data=spm_read_vols(ROI_vol);
ROI_data(ROI_data>=minThreshVal)=1;
ROI_data(ROI_data<minThreshVal)=0;

infoVol = ROI_vol;
infoVol.fname=['D:\NPAD\' ExpCode '\NPAD_Experiment_v2_' SubCode '\ROIs\JLF\CA1_mask.nii'];
infoVol=rmfield(infoVol,'pinfo'); 
spm_write_vol(infoVol,ROI_data);

ROI_mask=infoVol.fname;