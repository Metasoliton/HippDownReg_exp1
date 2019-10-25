function preProcessSubNat(sub_code) 


%% slicetime correction

for s=1:610; tmp{1}(s) = cellstr( ['../Data/NPAD/sub-' sub_code '/func/sub-' sub_code '_NFB.nii,' num2str(s) ]); end
matlabbatch{1}.spm.temporal.st.scans{1}=tmp{1}';

matlabbatch{1}.spm.temporal.st.nslices = 45;
matlabbatch{1}.spm.temporal.st.tr = 3;
matlabbatch{1}.spm.temporal.st.ta = 2.93333333333333;
matlabbatch{1}.spm.temporal.st.so = [1 8 15 22 29 36 43 2 9 16 23 30 37 44 3 10 17 24 31 38 45 4 11 18 25 32 39 5 12 19 26 33 40 6 13 20 27 34 41 7 14 21 28 35 42];
matlabbatch{1}.spm.temporal.st.refslice = 11;
matlabbatch{1}.spm.temporal.st.prefix = 'a';

job = matlabbatch; spm_jobman('run',job); clear matlabbatch job; 


%% rest of preprocessing (realign & smooth)

tmp{1}(1)=cellstr(['../Data/NPAD/sub-' sub_code '/func/sub-' sub_code  '_mov_ref_img.nii,1' ]);  % reference image

for s=1:610; tmp{1}(s+1)=cellstr(['../Data/NPAD/sub-' sub_code '/func/asub-' sub_code '_NFB.nii,' num2str(s) ]); end
matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = tmp{1}';

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [1 0]; % ignore 1st image
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{2}.spm.spatial.smooth.fwhm = [4 4 4];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's';

job = matlabbatch; spm_jobman('run',job); clear matlabbatch job; 

%% fix realignment parameters (remove extra reference scan) 
 fid = fopen(['../Data/NPAD/sub-' sub_code '/func/rp_sub-' sub_code '_mov_ref_img.txt'], 'r') ;  fgetl(fid) ;  buffer = fread(fid, Inf) ;  fclose(fid);
 fid = fopen(['../Data/NPAD/sub-' sub_code '/func/rp_sub-' sub_code '_mov_ref_img.txt'], 'w')  ;  fwrite(fid, buffer) ;  fclose(fid) ;
