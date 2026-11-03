# ICC-physio-densemap
repository for OHBM2026 poster submission


Methods


For more information on the dataset, see Moia (2021). In order to answer the research questions, only the first resting-state of each session was analysed, as to avoid potential biases arising from task-related effects, tiredness, discomfort or sleepiness. Unless otherwise specified, all data processing and analyses described in the following sections refer to data collected during resting-state run 1.

Functional connectivity. In this work, functional connectivity between the 100, 400 and 1000 ROIs Schaefer's atlas was calculated in Matlab with the corr() function. To check the quality of the preprocessing output, we did a visual inspection of all connectomes – reorganized according to the 7 Yeo’s networks order.

Functional fingerprinting. As done in previous studies (Amico & Goñi, 2018; Stampacchia et al., 2024), we decided to evaluate the identifiability of the functional fingerprints with Intraclass Correlation Coefficient (ICC). This index was computed edgewise and cumulatively (referred to in the text as: dense-sampling ICC), meaning that ICC was calculated on edges from 1 to n sessions for a total of 9 ICC matrices per atlas and denoising method. ICC edge values are comprised between -1 and 1, a score closer to 1 reflecting a higher inter-subject than intra-subject variability across raters, here represented by the sessions. 
We opted for the ICC model 2-1 (two-way random effects, absolute agreement, single rater/measurement; see Koo and Li 2017). We used the Matlab’s implementation by Salarian (2008).
  
ICCedge = (MSR - MSE) / (MSR + (k-1)*MSE + k/n * MSC - MSE)

MSR = mean square for rows; MSW = mean square for residual sources of variance; MSE = mean square for error; MSC = mean square for columns; n = number of subjects; k = number of measurements, here independent sessions.


Template


/Template folder contains all templates I used for registration (anat ref:  MNI152lin_T1_1mm_brain.nii.gz from FSL: ~/fsl/data/linearMNI) and for timeseries extraction (Schaefer: https://github.com/ThomasYeoLab/CBIG/tree/master/stable_projects/brain_parcellation/Schaefer2018_LocalGlobal/Parcellations/MNI). I used the 7 networks order parcellisations, so:
Schaefer2018_100Parcels_7Networks_order_FSLMNI152_1mm.nii.gz
Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii.gz
Schaefer2018_1000Parcels_7Networks_order_FSLMNI152_1mm.nii.gz

Then I dilate and resampled them at 2.5mm, as shown in 1_registration.sh, and I manually reordered labels in order to have ROIs from different hemispheres but same network close to each other.


Scripts


Everything can be done in the container, except for manual peak check/correction, since the container doesn't support images. It can be built with:
apptainer build -f namecontainer.sif  dir/EuskalIBUR_preproc.def

Generally, one should start with physiological peak detection, with 0_physio_preproc.py. If you already have minimally preprocessed data, you can directly run 1_registration.sh --> 0_noise_regression.sh --> 2_timeseries_extraction.sh --> 3_functional_connectivity.m --> 4_ICC_ds.m --> 5_poster_figures.m
If not, you need to follow what done by Stefano Moia in https://github.com/smoia/EuskalIBUR_preproc.

0_noise_regression.sh = 8 denoising models, after which you need to extract timeseries.

0_physio_preproc.py = physiological signal (PPG, chest belt) peak detection and potentially manual correction. Then, functions to get HRV, RVT and RETROICOR regressors.

1_registration.sh = to register the segmented T1w to functional space (single band reference, sbref). It uses transforms from T1 to T2 and T2 to sbref. In the same file, seg2sbref different tissues are splitted (CSF2sbref, ZM2sbref, GM2sbref), both CSF and WM are shrinked to be sure they don't contain GM. The volume is recomposed and used as a mask to extract CSF and WM average values that will be used as regressors. Then the Schaefer atlas is dilated (100, 400, 1000 parcels) and registered to functional space.

2_timeseries_extraction.sh = timeseries extraction with 3dROIstats.

3_functional_connectivity.m = the script is with Schaefer 400 but of course FC has to be calculated for 100, 400 and 1000 parcels. The script contains also commands to get connectomes (symmetrical matrix figures).

4_ICC_ds.m = dense sampling ICC computed edge-wise; I stored additional values (MSE, MSR, MSC…). This script allows to get plots of ICC matrices, 9 per atlas and denoising model.

5_figures.m and 5_poster_figures.m = more or less same script, the first one was for the abstract submission while the second is to reproduce the poster figures.
