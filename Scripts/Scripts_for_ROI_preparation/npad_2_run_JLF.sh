#!/bin/bash

inData=${1}
JLF_home=${2}

fileName=$(basename ${inData})
dirName=$(dirname ${inData})

mkdir ${dirName}/JLF/

nice bash ${JLF_home}/ANTs_JLF/antsJointLabelFusion.sh -c 2 -j 5   \
-t ${inData}    \
-d 3    \
-o ${dirName}/JLF/malf \
-p ${dirName}/JLF/malfPosteriors%04d.nii.gz \
-g ${JLF_home}/CobraLab_atlases/brains_t1_nifti/brain1_t1.nii.gz -l ${JLF_home}/CobraLab_atlases/atlases-nifti/hippocampus-subfields/labels/brain1_labels.nii -g ${JLF_home}/CobraLab_atlases/brains_t1_nifti/brain2_t1.nii.gz -l ${JLF_home}/CobraLab_atlases/atlases-nifti/hippocampus-subfields/labels/brain2_labels.nii -g ${JLF_home}/CobraLab_atlases/brains_t1_nifti/brain3_t1.nii.gz -l ${JLF_home}/CobraLab_atlases/atlases-nifti/hippocampus-subfields/labels/brain3_labels.nii -g ${JLF_home}/CobraLab_atlases/brains_t1_nifti/brain4_t1.nii.gz -l ${JLF_home}/CobraLab_atlases/atlases-nifti/hippocampus-subfields/labels/brain4_labels.nii -g ${JLF_home}/CobraLab_atlases/brains_t1_nifti/brain5_t1.nii.gz -l ${JLF_home}/CobraLab_atlases/atlases-nifti/hippocampus-subfields/labels/brain5_labels.nii 
           
fsl5.0-fslchfiletype NIFTI ${dirName}/JLF/malfPosteriors0001.nii.gz  ${dirName}/JLF/sub-${sub}_right_CA1.nii
fsl5.0-fslchfiletype NIFTI ${dirName}/JLF/malfPosteriors0101.nii.gz  ${dirName}/JLF/sub-${sub}_left_CA1.nii

fsl5.0-fslmaths ${dirName}/JLF/malfPosteriors0001.nii.gz -add ${dirName}/JLF/malfPosteriors0101.nii.gz  ${dirName}/JLF/sub-${sub}_bilat_CA1.nii.gz
fsl5.0-fslchfiletype NIFTI  ${dirName}/JLF/sub-${sub}_bilat_CA1.nii.gz    ${dirName}/JLF/sub-${sub}_bilat_CA1.nii
           
