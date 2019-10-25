importfile(['.\ROIs\JFL_2_ROI.mat']);  
%%
base=pwd; cd ./ROIs/JLF; ROI_dir=pwd; cd(base);

matlabbatch{1}.spm.util.imcalc.input{1}=[ROI_dir '/sub-'  '_left_CA1.nii,1'];
matlabbatch{1}.spm.util.imcalc.input{2}=[ROI_dir '/sub-'  '_right_CA1.nii,1'];

matlabbatch{1}.spm.util.imcalc.outdir=cellstr([ROI_dir]);

matlabbatch{1}.spm.util.imcalc.output=['sub-' SubCode '_bilat_CA1.nii,1'];

%%
cd ./LocalizerData/; ref_data=pwd; flist=dir; cd(base); % from localizer scan
matlabbatch{2}.spm.spatial.coreg.estwrite.ref = cellstr([ref_data '/' flist(12).name  ',1']);
matlabbatch{2}.spm.spatial.coreg.estwrite.source=cellstr([ROI_dir '/sub-' SubCode '_T1w_N4_mabonlm_brain.nii,1']);

matlabbatch{2}.spm.spatial.coreg.estwrite.other{1}=[ROI_dir '\sub-' SubCode '_bilat_CA1.nii,1'] ; % from imcalc above
matlabbatch{2}.spm.spatial.coreg.estwrite.other{2}= [ROI_dir '\sub-' SubCode '_T1w_N4_mabonlm.nii,1'] ; % from imcalc above
matlabbatch{2}.spm.spatial.coreg.estwrite.other{3}= [ROI_dir '\p2sub-' SubCode '_T1w_N4_mabonlm.nii,1'] ; % from imcalc above
matlabbatch{2}.spm.spatial.coreg.estwrite.other{4}= [ROI_dir '\p2sub-' SubCode '_T1w_N4_mabonlm_bin.nii,1'] ; % from imcalc above


job = matlabbatch; spm_jobman('run',job); clear matlabbatch job;
%% Binarize

ROI = [ROI_dir '/r' 'sub-' SubCode '_bilat_CA1.nii,1']; % resliced to fMRI space

ROI_indices=spm_summarise(ROI,'all',@find)'; % gives indices
ROI_weights=spm_summarise(ROI,ROI)';         % gives values

[W,I] = sort(ROI_weights);
W_MLV = W(end-round(end/10) : end)'; % weights in top 10% most likely voxels
I_MLV = I(end-round(end/10) : end)'; % indices of top 10% most likely voxels

minThreshVal=min(W_MLV);

ROI_vol = spm_vol(ROI);  
ROI_data=spm_read_vols(ROI_vol);

ROI_data(ROI_data>=minThreshVal)=1;
ROI_data(ROI_data<minThreshVal)=0;
numOf_NFB_voxels=nnz(ROI_data==1)

infoVol = ROI_vol;
infoVol.fname=['.\ROIs\JLF\CA1_mask.nii'];
infoVol=rmfield(infoVol,'pinfo'); 
spm_write_vol(infoVol,ROI_data);

ROI_mask=infoVol.fname;

%% FOR PLOTTING
%{

flist=ls('.\realtimedata\*.nii')
 
for vol=1:length(flist); 
    % load data
    data=spm_summarise(['.\realtimedata\' flist(vol,:)],ROI);
    DATA(:,vol)=reshape(data,[],1);
end 

MEAN=mean(DATA);
MODE=mode(DATA);
MEDIAN=median(DATA);
figure; plot(MEAN,'r'); hold on; plot(MEDIAN,'b'); hold off; clear DATA data;

%}