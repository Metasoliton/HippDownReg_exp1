importfile(['.\ROIs\coreg_2_rt.mat']);  

base=pwd; cd ./LocalizerData/; ref_data=pwd; flist=dir; cd(base); % from localizer scan
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = cellstr([ref_data '/' flist(3).name  ',1']);

cd ./sMRI; MRI_data=pwd; cd(base);
cd(MRI_data); flist = dir('m*'); cd(base); % bias corrected T1
matlabbatch{1}.spm.spatial.coreg.estwrite.source=cellstr([MRI_data '/' flist(1).name  ',1']);

cd ./ROIs/WFU_PickAtlas; ROI_data=pwd; cd(base);
cd(ROI_data); flist = dir('w*'); cd(base); % ROIs
matlabbatch{1}.spm.spatial.coreg.estwrite.other{1}=[ROI_data '/' flist(1).name  ',1'];
matlabbatch{1}.spm.spatial.coreg.estwrite.other{2}=[ROI_data '/' flist(1).name  ',1']; 

job = matlabbatch; spm_jobman('run',job); clear matlabbatch job;

