#!/bin/bash 

export FREESURFER_HOME=/usr/local/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

mkdir ../Data/NPAD/FreeSurfer
export SUBJECTS_DIR=../Data/NPAD/FreeSurfer


inSUBs="  ... # ENTER PARTICIPANT IDs HERE # ... "


for sub in $inSUBs
do
  echo checking subject ${sub}

if [ ! -e "../Data/NPAD/FreeSurfer/${sub}/stats/aseg.stats" ]; then  

  if [ -e "../Data/NPAD/sub-${sub}/anat/preNFB/sub-${sub}_T1w_N4_mabonlm.nii" ]; then  
  
  echo CURRENTLY PROCESSING subject ${sub}
  nice recon-all -all -subjid ${sub} -i ../Data/NPAD/sub-${sub}/anat/preNFB/sub-${sub}_T1w_N4_mabonlm.nii
  fi
fi

done



asegstats2table --subjects ${inSUBs} --meas volume --tablefile aseg_stats.txt

 
 
