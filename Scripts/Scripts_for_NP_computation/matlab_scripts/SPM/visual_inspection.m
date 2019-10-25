% prior normalization
flist=dir;
for folder=14:82   
cd([flist(folder).name])
spm_check_registration(['anat/postNFB/' flist(folder).name '_brain.nii,1'],['anat/postNFB/r' flist(folder).name '_GM.nii,1'], ['func/ra' flist(folder).name '_NFB.nii,100'], ['anat/postNFB/' flist(folder).name '_CA1.nii,1']) 
pause
cd ../
end

% after normalization
flist=dir;
for folder=75:82
cd([flist(folder).name])
spm_check_registration(['anat/postNFB/SyN_' flist(folder).name '_brain.nii,1'],['anat/postNFB/SyN_r' flist(folder).name '_GM.nii,1'], ['func/SyN_conn_ra' flist(folder).name '_NFB.nii,100'], ['anat/postNFB/SyN_' flist(folder).name '_CA1.nii,1']) 
pause
cd ../
end




























