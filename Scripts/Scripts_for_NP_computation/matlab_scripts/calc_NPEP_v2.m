function calc_NPEP_v2(sub, step, out_file)

if ~exist(['../Data/NPAD/' out_file], 'file')
 fid=fopen(['../Data/NPAD/' out_file],'w'); fprintf(fid, '%s \r', 'sub NPreg'); fclose(fid);
end

display(['!!!! COMPUTING NPEP METRICS !!!!    (on  ' step  '  data)'])

  TS_CA1=mean(spm_summarise(['../Data/NPAD/sub-' sub '/func/' step 'sub-' sub '_NFB.nii'], ['../Data/NPAD/sub-' sub '/anat/postNFB/sub-' sub '_CA1.nii']),2) ; 
  opt_reg=[(ones(40,1)'+569) (570':-1:1) ] ;
  try; NPreg=corr(TS_CA1,opt_reg'); catch ; NPreg='999';end
  
  fid=fopen(['../Data/NPAD/' out_file],'a'); fprintf(fid, '%s \r', [sub ' ' num2str(NPreg) ]); fclose(fid);

end

