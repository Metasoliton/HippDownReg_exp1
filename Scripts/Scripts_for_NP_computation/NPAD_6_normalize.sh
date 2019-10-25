#!/bin/bash

# MOVE confound corrected timeseries to corresponding subject directory
files2move=`ls ./matlab_scripts/conn/conn_NPAD/results/preprocessing/niftiDATA_Subject???_Condition000.nii`

############
echo REVERSE NAME CHANGING PREPARATION for ART
for sub in ${SUBs}; do
mv ../Data/NPAD/sub-${sub}/anat/postNFB/CA1_sub-${sub}_CA1.nii         ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_CA1.nii    
mv ../Data/NPAD/sub-${sub}/anat/postNFB/brain_rsub-${sub}_brain.nii    ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_brain.nii 
mv ../Data/NPAD/sub-${sub}/anat/postNFB/CSF_rsub-${sub}_CSF.nii        ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_CSF.nii   
mv ../Data/NPAD/sub-${sub}/anat/postNFB/GM_rsub-${sub}_GM.nii          ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_GM.nii    
mv ../Data/NPAD/sub-${sub}/anat/postNFB/WM_rsub-${sub}_WM.nii          ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_WM.nii    
mv  ../Data/NPAD/sub-${sub}/func/rp_rasub-${sub}_NFB.txt ../Data/NPAD/sub-${sub}/func/rp_sub-${sub}_mov_ref_img.txt
done
############


# # make/check list of subjects	
subjectDir=( `ls -d ../Data/NPAD/*` )  # array indexing starts from 0
for (( subNum = 0 ;  subNum <=  47;  subNum++  ));  # 0-47 ~ 48 subjects
do
echo $(basename ${subjectDir[subNum]})
done

subNum=0 ;  
for file in ${files2move}
do
    sub=$(basename ${subjectDir[subNum]})
    echo ${subjectDir[subNum]}
    echo $file 
    mv $file ${subjectDir[subNum]}/func
    subNum=`echo "( $subNum + 1 )" | bc`;     
done


############################################################################################################################################################################

# RE-SCALE and mask functional data
for sub in ${SUBs}; do
 echo $sub
 if [ ! -e "../Data/NPAD/sub-${sub}/func/conn_rasub-${sub}_NFB.nii" ]; then 
  echo scaling data $sub
  inFile=`ls ../Data/NPAD/sub-${sub}/func/niftiDATA_Subject???_Condition000.nii`
  sh ./scale_NII.sh ${inFile}
  fsl5.0-fslmaths ${inFile}_scaled.nii.gz -mul ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_GM.nii ../Data/NPAD/sub-${sub}/func/conn_rasub-${sub}_NFB.nii.gz 
  rm ${inFile}_scaled.nii.gz ;
  fslchfiletype NIFTI ../Data/NPAD/sub-${sub}/func/conn_rasub-${sub}_NFB.nii.gz
 fi
done
############################################################################################################################################################################

# normalize T1, EPI and GM
for sub in ${SUBs}; do
echo NORMALIZING sub-${sub}
nice bash /media/sci01/3746-6572/myApps/SyGN_normalize/SyGN_normalize_ed.sh ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_brain.nii  ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_GM.nii ../Data/NPAD/sub-${sub}/func/conn_rasub-${sub}_NFB.nii
done


# normalize ROI-CA1
for sub in $SUBs
do
if [ ! -e "../Data/NPAD/sub-${sub}/anat/postNFB/SyN_sub-${sub}_CA1.nii" ]; then

  inDataT1=../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_brain.nii  
  inDataGM=../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_CA1.nii

  T1_fileName=$(basename ${inDataT1})
  T1_dirName=$(dirname ${inDataT1})
  GM_fileName=$(basename ${inDataGM})
  GM_dirName=$(dirname ${inDataGM})

  echo APPLYING DEFORMATION MATRIX to CA1 mask; 
  antsApplyTransforms \
  -d 3 -r /media/sci01/3746-6572/pre2017_archive/2b_Aetionomy_corssectional_100/Data/StartedOn15thMar2016/MNI/ICBM_BRAIN_MNI_3mm.nii     -i ${inDataGM}  -e 0 \
  -t /media/sci01/3746-6572/pre2017_archive/2b_Aetionomy_corssectional_100/Data/StartedOn15thMar2016/sMRI/MultiVarCustomTemplate/TMP/CustomTMP_2_ICBM_MNI_1Warp.nii.gz \
  -t /media/sci01/3746-6572/pre2017_archive/2b_Aetionomy_corssectional_100/Data/StartedOn15thMar2016/sMRI/MultiVarCustomTemplate/TMP/CustomTMP_2_ICBM_MNI_0GenericAffine.mat \
  -t ${T1_dirName}/T1_2_CustomTMP_1Warp.nii.gz                     -t ${T1_dirName}/T1_2_CustomTMP_0GenericAffine.mat \
  -o ${GM_dirName}/SyN_${GM_fileName}
      
fi    
done

############################################################################################################################################################################
############################################################################################################################################################################
############################################################################################################################################################################
############################################################################################################################################################################
############################################################################################################################################################################











