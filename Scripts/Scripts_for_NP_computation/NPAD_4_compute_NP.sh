#!/bin/bash

####### set parameters & paths (must be consistent in any Matlab scripts/batches (e.g. slice-time correction)
FWHM="6"
total_smoothness="11" 
ANALYSIS='pos' 
TR="3" 


export FREESURFER_HOME=/usr/local/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export FSL_HOME=/usr/share/fsl/5.0/
export MCroot_HOME=/usr/local/MATLAB/R2016a/MCR901/v901
####################################################################################################
####################################################################################################

# specify data storage path
DATA_on_NAS="  ... # ENTER PATH TO DATABASE HERE # ... "

# Specify subjects to process
SUBs="  ... # ENTER PARTICIPANT IDs HERE # ... "

for sub in ${SUBs}; do

 echo CHECKING SOURCE DATA SUB-${sub}

 # organize folders from preNFB processing
 if [ ! -e "../Data/NPAD/sub-${sub}/anat/preNFB/" ]; then  
 echo ORGANIZING DATA SUB-${sub}; mkdir ../Data/NPAD/sub-${sub}/anat/preNFB/ ; sleep 5; mv ../Data/NPAD/sub-${sub}/anat/* ../Data/NPAD/sub-${sub}/anat/preNFB/ ; 
 fi

 if [ ! -e "../Data/NPAD/sub-${sub}/func/sub-${sub}_NFB.nii" ]; then
  fslmerge -tr ../Data/NPAD/sub-${sub}/func/sub-${sub}_NFB    ${DATA_on_NAS}/NPAD_Experiment_v2_${sub}/realtimedata/Volume*.nii ${TR} ; 
  fslchfiletype NIFTI ../Data/NPAD/sub-${sub}/func/sub-${sub}_NFB
  fi 
  
  
 if [ ! -e "../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_CSF.nii" ]; then mkdir ../Data/NPAD/sub-${sub}/anat/postNFB 
  cp ${DATA_on_NAS}/NPAD_Experiment_v2_${sub}/LocalizerData/Volume010.nii                    ../Data/NPAD/sub-${sub}/func/sub-${sub}_mov_ref_img.nii
  cp ${DATA_on_NAS}/NPAD_Experiment_v2_${sub}/ROIs/JLF/rsub-${sub}_T1w_N4_mabonlm_brain.nii  ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_brain.nii
  cp ${DATA_on_NAS}/NPAD_Experiment_v2_${sub}/ROIs/JLF/CA1_mask.nii                          ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_CA1.nii
  fslchfiletype NIFTI ../Data/NPAD/sub-${sub}/anat/preNFB/sub-${sub}_T1w_N4_mabonlm_brain.nii.gz
  cp                  ../Data/NPAD/sub-${sub}/anat/preNFB/sub-${sub}_T1w_N4_mabonlm_brain.nii    ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_brain.nii
  cp ../Data/NPAD/sub-${sub}/anat/preNFB/p1sub-${sub}_T1w_N4_mabonlm.nii       ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_GM.nii
  cp ../Data/NPAD/sub-${sub}/anat/preNFB/p2sub-${sub}_T1w_N4_mabonlm.nii       ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_WM.nii
  cp ../Data/NPAD/sub-${sub}/anat/preNFB/p3sub-${sub}_T1w_N4_mabonlm.nii       ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_CSF.nii   ; 
 fi

# corrective measures (for early subjects with non-brain-peeled T1 data prior to NPAD visit)
 if [ ! -e "../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_brain.nii" ]; then 
  echo CORRECTIVE MEASURES SUB-${sub}
  cp ../Data/NPAD/sub-${sub}/anat/preNFB/sub-${sub}_T1w_N4_mabonlm_brain.nii     ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_brain_tmp.nii 
/usr/local/MATLAB/R2014a/bin/matlab -nodesktop -nojvm -nosplash -r "addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/special_functions'));addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/spm12/')); addpath(genpath('./')); try; coresl2ref('../Data/NPAD/sub-${sub}/func/sub-${sub}_mov_ref_img.nii','../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_brain_tmp.nii'); catch; end ;quit;"
  mv ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_brain_tmp.nii ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_brain.nii
  rm ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_brain_tmp.nii   ; 
 fi
 
# coregistration to reference volume 
 if [ ! -e "../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_CSF.nii" ]; then 
/usr/local/MATLAB/R2014a/bin/matlab -nodesktop -nojvm -nosplash -r "addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/special_functions'));addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/spm12/')); addpath(genpath('./')); try; coReslMulti2ref('../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_brain.nii','../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_brain.nii', '../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_CSF.nii', '../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_GM.nii', '../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_WM.nii'); catch; end ;quit;"   ; 
 fi

# preprocessing in native space for NP estimation 
 if [ ! -e "../Data/NPAD/sub-${sub}/func/srasub-${sub}_NFB.nii" ]; then 
/usr/local/MATLAB/R2014a/bin/matlab -nodesktop -nojvm -nosplash -r "addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/special_functions'));addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/spm12/')); addpath(genpath('./')); try; preProcessSubNat('${sub}'); catch; end ;quit;" ;
 fi
 
# Compute Neurofeedback Performance from non-smoothed data
echo CHECKING SPM DATA SUB-${sub}
/usr/local/MATLAB/R2014a/bin/matlab -nodesktop -nojvm -nosplash -r "addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/special_functions'));addpath(genpath('/media/sci01/40b1b722-b871-411e-8d16-87d356b6c85e1/ARCHIVE/my_toolboxes/spm12/')); addpath(genpath('./')); display('${sub}');  calc_NPEP_v2('${sub}','ra','NPEP_metrics_nosmooth.txt'); fid=fopen(['../Data/NPAD/sub-${sub}/func/NPEP_ra_computed'],'a'); fclose(fid);quit;" ;
 
done







