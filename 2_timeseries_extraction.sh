#!/usr/bin/env bash
# Laura Belli, Stefano Moia
# last modification: 15.12.2025
# timeseries extraction
models=("m1" "m2" "m3" "m4" "m5" "m6" "m7" "m8")
atlases=("100" "400" "1000")
wdr=/wdr
res=/results
for atlas in "${atlases[@]}"; do
    for sub in $(seq -f %03g 1 10); do 
        echo "processing Schaefer${atlas} sub-${sub}"
        for ses in $(seq -f %02g 1 10); do
            for model in "${models[@]}"; do 
                flpr=sub-${sub}_ses-${ses}
                  3dROIstats -numROI ${atlas} -zerofill 0 -quiet -mask ${wdr}/sub-${sub}_Schaefer${atlas}2sbref_mask.nii.gz ${wdr}/${flpr}_task-rest_run-01_optcom_bold_${model}.nii.gz \
                  > ${res}/sub-${sub}_ses-${ses}_task-rest_run-01_Schaefer${atlas}_timeseries_${model}.1D
            done
        done
    done
done