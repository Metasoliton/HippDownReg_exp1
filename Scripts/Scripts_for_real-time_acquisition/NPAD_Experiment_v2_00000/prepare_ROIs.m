importfile(['.\prepROI.mat']);  

matlabbatch{1}.spm.spatial.preproc.channel.vols{1} = ['T1raw.nii,1']

matlabbatch{2}.spm.spatial.normalise.write.subj.resample{1} = ['D:\NPAD\RETIF_test1\Software\Stavros\NPAD_Experiment_v0\ROIs\WFU_PickAtlas\hippocampus_dil0.nii,1']
matlabbatch{2}.spm.spatial.normalise.write.subj.resample{2} = ['D:\NPAD\RETIF_test1\Software\Stavros\NPAD_Experiment_v0\ROIs\WFU_PickAtlas\hippocampus_dil1.nii,1']
matlabbatch{2}.spm.spatial.normalise.write.subj.resample(3)=[];

cd ../LocalizerData/; flist=dir; matlabbatch{3}.spm.spatial.coreg.estwrite.ref{1} = [flist(3).name  ',1'];

%Run the job
job = matlabbatch; spm_jobman('run',job); clear matlabbatch











