#!/bin/bash

### Renaming in a way that facilitates loading the files into the MIT connectivity toolbox (v17)
echo PREPARING for ART
for sub in ${SUBs}; do
mv ../Data/NPAD/sub-${sub}/anat/postNFB/sub-${sub}_CA1.nii    ../Data/NPAD/sub-${sub}/anat/postNFB/CA1_sub-${sub}_CA1.nii
mv ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_brain.nii ../Data/NPAD/sub-${sub}/anat/postNFB/brain_rsub-${sub}_brain.nii
mv ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_CSF.nii   ../Data/NPAD/sub-${sub}/anat/postNFB/CSF_rsub-${sub}_CSF.nii
mv ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_GM.nii    ../Data/NPAD/sub-${sub}/anat/postNFB/GM_rsub-${sub}_GM.nii
mv ../Data/NPAD/sub-${sub}/anat/postNFB/rsub-${sub}_WM.nii    ../Data/NPAD/sub-${sub}/anat/postNFB/WM_rsub-${sub}_WM.nii
mv ../Data/NPAD/sub-${sub}/func/rp_sub-${sub}_mov_ref_img.txt ../Data/NPAD/sub-${sub}/func/rp_rasub-${sub}_NFB.txt
mv  ../Data/NPAD/sub-${sub}/func/rasub-${sub}_NFB.nii  ../Data/NPAD/sub-${sub}/func/FUNC_rasub-${sub}_NFB.nii
done


# NOTE: Manual action required:
# Load the data into the MIT connectivity toolbox (v17) and if necessary adapt settings according to screeshots in Scripts/matlab_scripts/conn/screenshots_settings
# You have to load appropriate files into Basic, Structural, functional and ROIs ...
# then run [Preprocessing > ART-outlier correction, using liberal settings] ...
# then in [Covariates 1st-level] remove QA timelines as covariates and assign correct files as realignment parameters.
# then press [Done] and [Start].
# When the first step is done, the Denoising tab will appear. Press [Done] and [Start] again.
# After that you can close Matlab and continue with NPAD_7_normalize.sh
