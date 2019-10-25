#!/bin/bash

FWHM="6"
total_smoothness="11" 
ANALYSIS='pos'

SUBs="  ... # ENTER PARTICIPANT IDs HERE # ... "

echo ECM processing  ....................
for sub in $SUBs
do

# rm ../Data/NPAD/sub-${sub}/func/${sub}_a_ecm_pos.v

  if [ ! -s ../Data/NPAD/sub-${sub}/anat/postNFB/mni_MRI_${sub}_a.v ] ; then     rm ../Data/NPAD/sub-${sub}/anat/postNFB/mni_MRI_${sub}_a.v ;   fi  # delete empty/false files
  if [ ! -e "../Data/NPAD/sub-${sub}/anat/postNFB/mni_MRI_${sub}_a.v" ]; then
    echo %%% IMPORTING TO LIPSIA %%% ${sub}
    
    vvinidi   -in  ../Data/NPAD/sub-${sub}/func/SyN_conn_rasub-${sub}_NFB.nii -out ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpA.v  -tr 3 -repn float
      vattredit -in ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpA.v -out ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpB.v -name "ca"     -value "30 30 37.3333321" 
      vattredit -in ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpB.v -out ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpC.v -name "cp"     -value "30 39 37.3333321" 
      vattredit -in ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpC.v -out ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk.v      -name "extent" -value "140 175 131"

      rm ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpA.v  
      rm ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpB.v 
      rm ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk_tmpC.v     
      
    vvinidi   -in  ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_sub-${sub}_brain.nii     -out ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_t1_${sub}_a.v      -repn s16bit
    vattrcopy -in  ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_t1_${sub}_a.v       -image ../Data/MNI/ICBM_BRAIN_MNI.v    -out ../Data/NPAD/sub-${sub}/anat/postNFB/mni_MRI_${sub}_a.v   # to copy missing ca, cp and extent values

    rm ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_t1_${sub}_a.v
  fi


  if [ ! -s ../Data/NPAD/sub-${sub}/anat/postNFB/mni_mask_${sub}_a.v ] ; then     rm ../Data/NPAD/sub-${sub}/anat/postNFB/mni_mask_${sub}_a.v ;   fi  # delete empty/false files
  if [ ! -e "../Data/NPAD/sub-${sub}/anat/postNFB/mni_mask_${sub}_a.v" ]; then
    vvinidi   -in  ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_rsub-${sub}_GM.nii     -out ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_${sub}_GM_a_s16bit.v  -repn s16bit
    vattrcopy -in ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_${sub}_GM_a_s16bit.v -image ../Data/MNI/ICBM_GM_MNI_3mm.v   -out ../Data/NPAD/sub-${sub}/anat/postNFB/mni_mask_${sub}_a.v  # to copy missing ca, cp and extent values
    rm ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_${sub}_GM_a_s16bit.v
  fi

done


for sub in $SUBs
do
################### SMOOTHING
  # delete empty/false files
  if [ ! -s ../Data/NPAD/sub-${sub}/func/${sub}_a_pre.v ] ; then     rm ../Data/NPAD/sub-${sub}/func/${sub}_a_pre.v ;   fi

  if [ ! -e "../Data/NPAD/sub-${sub}/func/${sub}_a_pre.v" ]; then
  echo preprocessing functional data from participant ${sub} ;  vpreprocess  -in ../Data/NPAD/sub-${sub}/func/SyN_${sub}_a_tmp2_GMmsk.v -out ../Data/NPAD/sub-${sub}/func/${sub}_a_pre.v -fwhm ${FWHM} -low 0 -high 90 -minval 1000  ; 
  fi
################### ECM
  # delete empty/false files
  if [ ! -s ../Data/NPAD/sub-${sub}/func/${sub}_a_ecm_${ANALYSIS}.v ] ; then     rm ../Data/NPAD/sub-${sub}/func/${sub}_a_ecm_${ANALYSIS}.v ;   fi

  if [ ! -e "../Data/NPAD/sub-${sub}/func/${sub}_a_ecm_${ANALYSIS}.v" ]; then
  echo computing ECM of participant ${sub} ;  vecm -in  ../Data/NPAD/sub-${sub}/func/${sub}_a_pre.v  -mask ../Data/NPAD/sub-${sub}/anat/postNFB/mni_mask_${sub}_a.v  -out ../Data/NPAD/sub-${sub}/func/${sub}_a_ecm_${ANALYSIS}.v -first 0 -length 610 -j 11 -type ${ANALYSIS}
  fi
done


################### FC: ROI-CA1
for sub in $SUBs
do
if [ ! -e "../Data/NPAD/sub-${sub}/func/FC/FC_seed_mni_CA1_mskd.v" ]; then
      
    vvinidi   -in  ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_sub-${sub}_CA1.nii     -out ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_CA1_${sub}_a.v      -repn s16bit
    vattrcopy -in  ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_CA1_${sub}_a.v       -image ../Data/MNI/ICBM_GM_MNI_3mm.v    -out ../Data/NPAD/sub-${sub}/anat/postNFB/mni_CA1_${sub}_a.v   # to copy missing ca, cp and extent values

    rm ../Data/NPAD/sub-${sub}/anat/postNFB/SyN_reg_CA1_${sub}_a.v

    mkdir ../Data/NPAD/sub-${sub}/func/FC/
    echo currently calculating FC of sub ${sub} 
    vcorr -in ../Data/NPAD/sub-${sub}/func/${sub}_a_pre.v -out ../Data/NPAD/sub-${sub}/func/FC/FC_seed_mni_CA1.v  -mask ../Data/NPAD/sub-${sub}/anat/postNFB/mni_CA1_${sub}_a.v  -type r2z ;

    vimagemask  -in ../Data/NPAD/sub-${sub}/func/FC/FC_seed_mni_CA1.v  -mask ../Data/MNI/ICBM_GM_MNI_3mm.v   -type inside  -min 22500 -max 100000  -out  ../Data/NPAD/sub-${sub}/func/FC/FC_seed_mni_CA1_mskd.v 
    
fi    
done

# visual inspection
for sub in $SUBs
do
vlv -in ../Data/MNI/ICBM_BRAIN_MNI_3mm.v ../Data/NPAD/sub-${sub}/anat/postNFB/mni_CA1_${sub}_a.v -z ../Data/NPAD/sub-${sub}/func/${sub}_a_ecm_${ANALYSIS}.v ../Data/NPAD/sub-${sub}/func/FC/FC_seed_mni_CA1.v 
done

