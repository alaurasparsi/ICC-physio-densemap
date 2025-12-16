#!/usr/bin/env bash
# Laura Belli, Stefano Moia
# last modification: 15.12.2025
pdir=/denoised_physio
sourcedr=/derivatives
wdr=/wdr
res=/results
polort=0

# prepare tissue regressors
for sub in $(seq -f %03g 1 10); do
    for ses in $(seq -f %02g 1 10); do
        RVT=${pdir}/RVT/correct/sub-${sub}_ses-${ses}_task-rest_run-01_RVT_resampled_lag-0
        HRV=${pdir}/HRV/correct/sub-${sub}_ses-${ses}_task-rest_run-01_HRV_resampled_convolved
        flpr=sub-${sub}_ses-${ses}
        # prepare WM and CSF regressors
        3dTproject -input ${wdr}/${flpr}_task-rest_run-01_avgtissues.1D \
        -polort ${polort} \
        -ort ${RVT}.1D \
        -ort ${HRV}.1D \
        -prefix ${wdr}/${flpr}_task-rest_run-01_avgtissue_reg.1D
        1dtranspose ${wdr}/${flpr}_task-rest_run-01_avgtissue_reg.1D > ${wdr}/${flpr}_task-rest_run-01_avgtissue_reg_f.1D
    done
done

# denoising
for sub in $(seq -f %03g 1 10); do
    for ses in $(seq -f %02g 1 10); do
        mref=${sourcedr}/sub-${sub}/ses-${ses}/reg/sub-${sub}_sbref
        RVT=${pdir}/RVT/sub-${sub}_ses-${ses}_task-rest_run-01_RVT_resampled_lag-0
        HRV=${pdir}/HRV/sub-${sub}_ses-${ses}_task-rest_run-01_HRV_resampled_convolved
        funcdir=${sourcedr}/sub-${sub}/ses-${ses}/func/sub-${sub}_ses-${ses}_task-rest_run-01_optcom_bold
        funcprfx=sub-${sub}_ses-${ses}_task-rest_run-01_optcom_bold
        func_in=${sourcedr}/sub-${sub}/ses-${ses}/func/00.sub-${sub}_ses-${ses}_task-rest_run-01_optcom_bold_native_preprocessed
        RETROICOR=${pdir}/RETROICOR/sub-${sub}_ses-${ses}_task-rest_run-01_RETROICOR_regressors
        flpr=sub-${sub}_ses-${ses}
        # 1.
        # motion denoised: motion paramenters (6), Legendre polynomials
        3dTproject -polort ${polort} -input ${func_in}.nii.gz  -mask ${mref}_brain_mask.nii.gz \
        -ort ${funcdir}_nuisreg_uncensored_mat.1D \
        -prefix ${wdr}/${funcprfx}_m1.nii.gz -overwrite
        # 2.
        # motion denoised with bandpass
        3dTproject -polort ${polort} -input ${func_in}.nii.gz  -mask ${mref}_brain_mask.nii.gz \
        -ort ${funcdir}_nuisreg_uncensored_mat.1D \
        -bandpass 0.01 0.15 \
        -prefix ${wdr}/${funcprfx}_m2.nii.gz -overwrite
        # 3.
        # non-physiological tissue denoised: motion paramenters (6), Legendre polynomials, WM and CSF denoised
        3dTproject -polort ${polort} -input ${func_in}.nii.gz  -mask ${mref}_brain_mask.nii.gz \
        -ort ${funcdir}_nuisreg_uncensored_mat.1D \
        -ort ${wdr}/${flpr}_task-rest_run-01_avgtissue_reg_f.1D \
        -prefix ${wdr}/${funcprfx}_m3.nii.gz -overwrite
        # 4.
        # non-physiological tissue denoised with bandpass
        3dTproject -polort ${polort} -input ${func_in}.nii.gz  -mask ${mref}_brain_mask.nii.gz \
        -ort ${funcdir}_nuisreg_uncensored_mat.1D \
        -ort ${wdr}/${flpr}_task-rest_run-01_avgtissue_reg_f.1D \
        -bandpass 0.01 0.15 \
        -prefix ${wdr}/${funcprfx}_m4.nii.gz -overwrite
        # 5.
        # tissue denoised: motion paramenters (6), Legendre polynomials, WM and CSF
        3dTproject -polort ${polort} -input ${func_in}.nii.gz  -mask ${mref}_brain_mask.nii.gz \
        -ort ${funcdir}_nuisreg_uncensored_mat.1D \
        -ort ${wdr}/${flpr}_task-rest_run-01_avgtissues.1D \
        -prefix ${wdr}/${funcprfx}_m5.nii.gz -overwrite
        # 6.
        # tissue denoised with bandpass
        3dTproject -polort ${polort} -input ${func_in}.nii.gz  -mask ${mref}_brain_mask.nii.gz \
        -ort ${funcdir}_nuisreg_uncensored_mat.1D \
        -ort ${wdr}/${flpr}_task-rest_run-01_avgtissues.1D \
        -bandpass 0.01 0.15 \
        -prefix ${wdr}/${funcprfx}_m6.nii.gz -overwrite
        # 7.
        # physiologically denoised: motion paramenters (6), Legendre polynomials, WM and CSF, HRV, RVT, RETROICOR
        3dTproject -polort ${polort} -input ${func_in}.nii.gz  -mask ${mref}_brain_mask.nii.gz \
        -ort ${func}_nuisreg_uncensored_mat.1D \
        -ort ${wdr}/${flpr}_task-rest_run-01_avgtissues.1D \
        -ort ${HRV}.1D \
        -ort ${RVT}.1D \
        -ort ${RETROICOR}.1D \
        -prefix ${wdr}/${funcprfx}_m7.nii.gz -overwrite
        # 8.
        # physiologically denoised with bandpass
        3dTproject -polort ${polort} -input ${func_in}.nii.gz  -mask ${mref}_brain_mask.nii.gz \
        -ort ${func}_nuisreg_uncensored_mat.1D \
        -ort ${wdr}/${flpr}_task-rest_run-01_avgtissues.1D \
        -ort ${HRV}.1D \
        -ort ${RVT}.1D \
        -ort ${RETROICOR}.1D \
        -bandpass 0.01 0.15 \
        -prefix ${wdr}/${funcprfx}_m8.nii.gz -overwrite
    done
done