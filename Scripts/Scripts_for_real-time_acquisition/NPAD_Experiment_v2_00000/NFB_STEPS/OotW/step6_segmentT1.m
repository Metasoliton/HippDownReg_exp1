
importfile(['.\ROIs\segmentT1.mat']);  

copyfile(['D:\NPAD\' ExpCode '/DATA/' SubCode '/T1/*.nii'],'.\sMRI');
base=pwd; cd ./sMRI; MRI_data=pwd; flist = dir('*.nii'); cd(base);

matlabbatch{1}.spm.spatial.preproc.channel.vols{1} = [MRI_data '/' flist(1).name  ',1'];

cd ./ROIs/WFU_PickAtlas; ROI_data=pwd; flist = dir('*'); cd(base);
matlabbatch{2}.spm.spatial.normalise.write.subj.resample{1} = [ROI_data '/' flist(3).name  ',1'];
matlabbatch{2}.spm.spatial.normalise.write.subj.resample{2} = [ROI_data '/' flist(4).name  ',1'];
matlabbatch{2}.spm.spatial.normalise.write.subj.resample(3)=[];

%Run the job
job = matlabbatch; spm_jobman('run',job); clear matlabbatch job;









