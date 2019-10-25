#!/bin/bash


# set path to apps e.g.
JLF_home="/path2apps/mk_JLF_masks"

# set project name (for BIDS naming)
projectName="NPAD"

# set subject codes e.g.
SUBs=" ... # ENTER PARTICIPANT IDs HERE # ..."


# # Archiving and unzipping XNAT downloads
# mkdir ../Data/Archive/
# mkdir ../Data/Archive/Sources
# cd ../Data/Archive/
# for f in *.zip; 
# do unzip -d "${f%*.zip}" "$f"; 
# done
# mv *zip ./Sources 
# cd -


for sub in ${SUBs}; do
# mk BIDS folders
if [ ! -e ../Data/${projectName} ] ;                  then mkdir ../Data/${projectName} ; fi
if [ ! -e ../Data/${projectName}/sub-${sub}/ ] ;      then mkdir ../Data/${projectName}/sub-${sub}/ ; fi
if [ ! -e ../Data/${projectName}/sub-${sub}/anat/ ] ; then mkdir ../Data/${projectName}/sub-${sub}/anat/ ; fi
if [ ! -e ../Data/${projectName}/sub-${sub}/func/ ] ; then mkdir ../Data/${projectName}/sub-${sub}/func/ ; fi
if [ ! -e ../Data/${projectName}/sub-${sub}/dwi/ ] ;  then mkdir ../Data/${projectName}/sub-${sub}/dwi/  ; fi
  
if [ -e "../Data/NPAD/sub-${sub}/anat/preNFB/" ]; then mv ../Data/NPAD/sub-${sub}/anat/preNFB/* ../Data/NPAD/sub-${sub}/anat/ ; rm ../Data/NPAD/sub-${sub}/anat/preNFB/  ; fi
  
# DCM2NII conversion
  if [ ! -e "../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4.nii.gz" ]; then
  dcm2nii -t Y -g Y -r N -x N -o   ../Data/${projectName}/sub-${sub}/anat ../Data/Archive/${sub}/scans/*/DICOM
  mv ../Data/${projectName}/sub-${sub}/anat/*RS* ../Data/${projectName}/sub-${sub}/func/
  mv ../Data/${projectName}/sub-${sub}/anat/*B0* ../Data/${projectName}/sub-${sub}/func/
  else echo ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4.nii.gz   ALREADY EXISTS ; fi

  # T1 preprocessing
  if [ ! -e "../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm.nii" ]; then
  nice N4BiasFieldCorrection -i ../Data/${projectName}/sub-${sub}/anat/*.nii.gz -o  ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4.nii.gz ; 
    fsl5.0-fslchfiletype NIFTI ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4.nii.gz  ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4.nii ; 
    /usr/local/MATLAB/R2014a/bin/matlab -nodesktop -nojvm -nosplash -r "addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/special_functions'));addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/spm8/'));addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/naonlm3d/'));mabonlm3D_nifti('../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4.nii','mabonlm');quit;"
  else echo ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm.nii   ALREADY EXISTS ; fi
done


#####
for sub in ${SUBs}; do
  # Joint Label Fusion (hippocampus)
  if [ ! -e "../Data/${projectName}/sub-${sub}/anat/JLF/sub-_bilat_CA1.nii" ]; then
  
  nice bash ./npad_2_run_JLF.sh   ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm.nii  ${JLF_home}
  else echo ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_bilat_CA1.nii   ALREADY EXISTS ; fi

  # Threshold and binarize JLF masks
  if [ ! -e "../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_left_CA1_ROI.nii" ]; then
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/JLF/sub-_left_CA1.nii.gz               -thr 0.2  ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_left_CA1_thr0p2.nii.gz
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_left_CA1_thr0p2.nii.gz           -bin  ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_left_CA1_thr0p2_bin.nii.gz
  fsl5.0-fslchfiletype NIFTI ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_left_CA1_thr0p2_bin.nii.gz ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_left_CA1_ROI.nii
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/JLF/sub-_right_CA1.nii.gz               -thr 0.2  ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_right_CA1_thr0p2.nii.gz
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_right_CA1_thr0p2.nii.gz           -bin  ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_right_CA1_thr0p2_bin.nii.gz
  fsl5.0-fslchfiletype NIFTI ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_right_CA1_thr0p2_bin.nii.gz ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_right_CA1_ROI.nii
  
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_right_CA1_thr0p2.nii.gz     -add ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_left_CA1_thr0p2.nii.gz ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_bilat_CA1_thr0p2.nii.gz
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_right_CA1_thr0p2_bin.nii.gz -add ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_left_CA1_thr0p2_bin.nii.gz ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_bilat_CA1_thr0p2_bin.nii.gz
  
  fsl5.0-fslchfiletype NIFTI ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_bilat_CA1_thr0p2.nii.gz ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_bilat_CA1_thr0p2.nii
  fsl5.0-fslchfiletype NIFTI ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_bilat_CA1_thr0p2_bin.nii.gz ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_bilat_CA1_ROI.nii
  
  else echo ../Data/${projectName}/sub-${sub}/anat/JLF/sub-${sub}_bilat_CA1.nii   ALREADY EXISTS ; fi
  
  # Peel Brains
  matlab_bin="/usr/local/MATLAB/R2014a/bin/matlab"
  tools_path="/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes"

  if [ ! -e "../Data/${projectName}/sub-${sub}/anat/p0sub-${sub}_T1w_N4_mabonlm.nii" ]; then
  bash ${tools_path}/spm8/toolbox/vbm8/cg_vbm8_batch.sh -m $matlab_bin -d matlab_scripts/my_vbm8_defaults.m  ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm.nii 
  echo waiting for NewSegment to finish
  while true; do sleep 5; if [ -e ../Data/${projectName}/sub-${sub}/anat/p0sub-${sub}_T1w_N4_mabonlm.nii  ]; then break; fi; done; sleep 5
  else echo p0sub-${sub}_T1w_N4_mabonlm.nii   ALREADY EXISTS ; fi

  # binarize whitematter for signal normalizing mask
  if [ ! -e "../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm_bin.nii" ]; then
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm.nii     -thrP 90 ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm_thrP90.nii
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm_thrP90.nii  -bin ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm_bin.nii
  fsl5.0-fslchfiletype NIFTI ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm_bin.nii.gz  ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm_bin.nii ; 
  else echo ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm_bin.nii   ALREADY EXISTS ; fi

  # binarize p0 and multiply with T1 to obtain peeled T1
  if [ ! -e "../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm_brain.nii" ]; then
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/p0sub-${sub}_T1w_N4_mabonlm.nii     -thr 0 ../Data/${projectName}/sub-${sub}/anat/p0sub-${sub}_T1w_N4_mabonlm_thr0.nii
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/p0sub-${sub}_T1w_N4_mabonlm_thr0.nii  -bin ../Data/${projectName}/sub-${sub}/anat/p0sub-${sub}_T1w_N4_mabonlm_bin.nii
  fsl5.0-fslmaths ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm.nii  -mul ../Data/${projectName}/sub-${sub}/anat/p0sub-${sub}_T1w_N4_mabonlm_bin.nii  ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm_brain.nii.gz
  fsl5.0-fslchfiletype NIFTI ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm_brain.nii.gz  ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm_brain.nii ; 
  else echo ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm_brain.nii   ALREADY EXISTS ; fi

done  
  

###### Transfer data to fMRI lab via NAS
mkdir ../Data/misc/transfer/
for sub in ${SUBs}; do
  mkdir ../Data/misc/transfer/${sub}/
  cp ../Data/${projectName}/sub-${sub}/anat/p0sub-${sub}_T1w_N4_mabonlm.nii                 ../Data/misc/transfer/${sub}/p0sub-${sub}_T1w_N4_mabonlm.nii    
  cp ../Data/${projectName}/sub-${sub}/anat/p1sub-${sub}_T1w_N4_mabonlm.nii                 ../Data/misc/transfer/${sub}/p1sub-${sub}_T1w_N4_mabonlm.nii    
  cp ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm.nii                 ../Data/misc/transfer/${sub}/p2sub-${sub}_T1w_N4_mabonlm.nii    
  cp ../Data/${projectName}/sub-${sub}/anat/p2sub-${sub}_T1w_N4_mabonlm_bin.nii             ../Data/misc/transfer/${sub}/p2sub-${sub}_T1w_N4_mabonlm_bin.nii
  cp ../Data/${projectName}/sub-${sub}/anat/p3sub-${sub}_T1w_N4_mabonlm.nii                 ../Data/misc/transfer/${sub}/p3sub-${sub}_T1w_N4_mabonlm.nii    
  cp ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm.nii                   ../Data/misc/transfer/${sub}/sub-${sub}_T1w_N4_mabonlm.nii      
  cp ../Data/${projectName}/sub-${sub}/anat/sub-${sub}_T1w_N4_mabonlm_brain.nii             ../Data/misc/transfer/${sub}/sub-${sub}_T1w_N4_mabonlm_brain.nii
  cp ../Data/${projectName}/sub-${sub}/anat/JLF/sub-_left_CA1.nii                           ../Data/misc/transfer/${sub}/sub-_left_CA1.nii  
  cp ../Data/${projectName}/sub-${sub}/anat/JLF/sub-_right_CA1.nii                          ../Data/misc/transfer/${sub}/sub-_right_CA1.nii 
done



