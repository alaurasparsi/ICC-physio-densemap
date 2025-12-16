#!/usr/bin/env bash
# Laura Belli, Stefano Moia
# last modification: 15.12.2025
sourcedr=/derivatives
wdr=/wdr
tmp=/tmp
aref=/ref_atlas
atlases=("100" "400" "1000")

# registration
for sub in $(seq -f %03g 1 10); do
    seg=${sourcedr}/sub-${sub}/ses-01/anat/sub-${sub}_ses-01_acq-uni_T1w_seg
    rdir=${sourcedr}/sub-${sub}/ses-01/reg
    mref=${rdir}/sub-${sub}_sbref
    T12std=${rdir}/sub-${sub}_ses-01_acq-uni_T1w2std
    T22T1=${rdir}/sub-${sub}_ses-01_T2w2acq-uni_T1w
    T22sbref=${rdir}/sub-${sub}_ses-01_T2w2sbref

    echo "Move seg in functional space"
    antsApplyTransforms -d 3 -i ${seg}.nii.gz \
                                        -r ${mref}.nii.gz \
                                        -o ${wdr}/sub-${sub}_seg2sbref.nii.gz -n MultiLabel \
                                        -t ${T22sbref}0GenericAffine.mat \
                                        -t [${T22T1}0GenericAffine.mat,1]

    3dcalc -a ${wdr}/sub-${sub}_seg2sbref.nii.gz -expr 'equals(a,1)' -prefix ${wdr}/sub-${sub}_CSF2sbref.nii.gz -overwrite
    3dcalc -a ${wdr}/sub-${sub}_seg2sbref.nii.gz -expr 'equals(a,3)' -prefix ${wdr}/sub-${sub}_WM2sbref.nii.gz -overwrite
    3dcalc -a ${wdr}/sub-${sub}_seg2sbref.nii.gz -expr 'equals(a,2)' -prefix ${wdr}/sub-${sub}_GM2sbref.nii.gz -overwrite
    # "dilate" (= shrink, since it's -1)
    3dmask_tool -input ${wdr}/sub-${sub}_CSF2sbref.nii.gz -prefix ${wdr}/sub-${sub}_CSF2sbref_eroded.nii.gz -dilate_input -1 -overwrite
    3dmask_tool -input ${wdr}/sub-${sub}_WM2sbref.nii.gz -prefix ${wdr}/sub-${sub}_WM2sbref_eroded.nii.gz -dilate_input -1 -overwrite
    # recompose CSF and WM
    fslmaths ${wdr}/sub-${sub}_GM2sbref.nii.gz -mas ${mref}_brain_mask.nii.gz ${wdr}/sub-${sub}_GM2sbref.nii.gz
    fslmaths ${wdr}/sub-${sub}_WM2sbref_eroded.nii.gz -mul 2 -add ${wdr}/sub-${sub}_CSF2sbref_eroded.nii.gz -mas ${mref}_brain_mask.nii.gz ${wdr}/sub-${sub}_WMCSF2sbref_eroded.nii.gz
    # use CSF and WM reference binary masks to get average values
    for ses in $(seq -f %02g 1 10); do
        fdir=${sourcedr}/sub-${sub}/ses-${ses}/func
        flpr=sub-${sub}_ses-${ses}
        func=${fdir}/00.${flpr}_task-rest_run-01_optcom_bold_native_preprocessed

        echo "Extract nuisance tissues averages subject ${sub}, session ${ses} rest run-01"
        fslmeants -i ${func}.nii.gz --label=${wdr}/sub-${sub}_WMCSF2sbref_eroded.nii.gz > ${wdr}/${flpr}_task-rest_run-01_avgtissue.1D
    done
done

# dilate atlas
for atlas in "${atlases[@]}"; do
    fslmaths ${aref}/Schaefer2018_${atlas}Parcels_7Networks_order_FSLMNI152_1mm.nii.gz -kernel 3D -dilD ${aref}/Schaefer${atlas}_dil.nii.gz
done

# register to functional space
for sub in $(seq -f %03g 1 10); do
    seg=${sourcedr}/sub-${sub}/ses-01/anat/sub-${sub}_ses-01_acq-uni_T1w_seg
    rdir=${sourcedr}/sub-${sub}/ses-01/reg
    mref=${rdir}/sub-${sub}_sbref
    T12std=${rdir}/sub-${sub}_ses-01_acq-uni_T1w2std
    T22T1=${rdir}/sub-${sub}_ses-01_T2w2acq-uni_T1w
    T22sbref=${rdir}/sub-${sub}_ses-01_T2w2sbref
    for atlas in "${atlases[@]}"; do
        echo "Move ${atlas} in func space"
        antsApplyTransforms -d 3 -i ${aref}/Schaefer${atlas}_dil.nii.gz \
                                                -r ${mref}.nii.gz \
                                                -o ${wdr}/sub-${sub}_Schaefer${atlas}2sbref.nii.gz -n MultiLabel \
                                                -t ${T22sbref}0GenericAffine.mat \
                                                -t [${T22T1}0GenericAffine.mat,1] \
                                                -t [${T12std}0GenericAffine.mat,1] \
                                                -t ${T12std}1InverseWarp.nii.gz -v

        fslmaths ${wdr}/sub-${sub}_Schaefer${atlas}2sbref.nii.gz -mas ${wdr}/sub-${sub}_GM2sbref.nii.gz ${wdr}/sub-${sub}_Schaefer${atlas}2sbref_mask.nii.gz
        #fslmeants -i ${wdr}/sub-${sub}_Schaefer${atlas}2sbref_masked.nii.gz --label=${wdr}/sub-${sub}_Schaefer${atlas}2sbref_masked --transpose ${wdr}/sub-${sub}_Schaefer${atlas}_labels.1D

    done
done