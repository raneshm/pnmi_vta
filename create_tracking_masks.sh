#!/bin/bash

BASE="/Volumes/psychology/Ellman_Group/Healthy_Brains_Project/Data/HBP_Data/MRI/derivatives/RM_ClusterBackup/DWI/hbp"
MNI="/Volumes/psychology/Ellman_Group/Healthy_Brains_Project/Data/HBP_Data/MRI/derivatives/RM_ClusterBackup/DWI/hbp/exclusion_MNI"

SUBJECTS="10013 10016 10017 10025 10029 10033 10036 10038 10039 10041 10051 10052 10055 10060 10065 10071 10082 10110 10116 10137 10139 10143 10156 10158 10160 10163 10168 10176 10177 10186 10189 10191 10215 10217 10219 10220 10225 10229 10237 10239 10245 10248 10253 10254 10255 10272 10279 10282 10292 10299 10308 10310 10323 10324 10331 10332 10337 10341 10357 10366 10369 10376 10381 10382 10388 10391 10392 10397 10400 10404 10421 10427 10430 10442 10444 10480 10494 10513 10524 10531 10541 10552 10557 10564 10572 10573 10594 10602 10608 10623 10625 10631 10655 10666 10668 10676 10691 10692 10693 10706 10711"

fslmaths ${MNI}/amygdala_0.5_bin.nii.gz -ero -bin ${MNI}/amygdala_exclusion_bin.nii.gz
fslmaths ${MNI}/fornix_mask_resampled_to_2mm_bin.nii.gz -thr 0.6 -bin ${MNI}/fornix_exclusion_bin.nii.gz

for s in ${SUBJECTS}
do
    mkdir -p ${BASE}/roi/diff_roi/sub-${s}
    mkdir -p ${BASE}/roi/exclusion/sub-${s}

    ln -sf ${BASE}/roi/exclusion_old/sub-${s}/exclusion_cortex_cerebellum.nii.gz ${BASE}/roi/exclusion/sub-${s}/cortex_exclusion_bin.nii.gz
    ln -sf ${BASE}/roi/diff_roi_old/sub-${s}/${s}_HPC_L_0.5_bin.nii.gz ${BASE}/roi/diff_roi/sub-${s}/HPC_L_0.5_bin.nii.gz
    ln -sf ${BASE}/roi/diff_roi_old/sub-${s}/${s}_HPC_R_0.5_bin.nii.gz ${BASE}/roi/diff_roi/sub-${s}/HPC_R_0.5_bin.nii.gz
    ln -sf ${BASE}/roi/diff_roi_old/sub-${s}/${s}_mean_VTA_thr0.5_bin.nii.gz ${BASE}/roi/diff_roi/sub-${s}/mean_VTA_thr0.5_bin.nii.gz
    ln -sf ${BASE}/roi/diff_roi_old/sub-${s}/${s}_T1_MNI_Rhemi_bin.nii.gz ${BASE}/roi/exclusion/sub-${s}/T1_MNI_Rhemi_bin.nii.gz
    ln -sf ${BASE}/roi/diff_roi_old/sub-${s}/${s}_T1_MNI_Lhemi_bin.nii.gz ${BASE}/roi/exclusion/sub-${s}/T1_MNI_Lhemi_bin.nii.gz

    fnirt --ref=${BASE}/dtifit_output_1000/sub-${s}/DTI_FA.nii.gz \
    --in=${MNI}/limbic_striatum_bin.nii.gz \
    --aff=${BASE}/transforms/sub-${s}/standard2diff_sub-${s}.mat \
    --iout=${BASE}/roi/diff_roi/sub-${s}/limbic_striatum_bin.nii.gz --verbose

    fnirt --ref=${BASE}/dtifit_output_1000/sub-${s}/DTI_FA.nii.gz \
    --in=${MNI}/fornix_exclusion_bin.nii.gz \
    --aff=${BASE}/transforms/sub-${s}/standard2diff_sub-${s}.mat \
    --iout=${BASE}/roi/diff_roi/sub-${s}/fornix_exclusion_bin.nii.gz --verbose

    fnirt --ref=${BASE}/dtifit_output_1000/sub-${s}/DTI_FA.nii.gz \
    --in=${MNI}/amygdala_exclusion_bin.nii.gz \
    --aff=${BASE}/transforms/sub-${s}/standard2diff_sub-${s}.mat \
    --iout=${BASE}/roi/diff_roi/sub-${s}/amygdala_exclusion_bin.nii.gz --verbose

    fslmaths ${BASE}/roi/diff_roi/sub-${s}/amygdala_exclusion_bin.nii.gz \
    -thr 0.75 -bin ${BASE}/roi/exclusion/sub-${s}/amygdala_exclusion_bin.nii.gz

    fslmaths ${BASE}/roi/diff_roi/sub-${s}/fornix_exclusion_bin.nii.gz \
    -sub ${BASE}/roi/diff_roi/sub-${s}/HPC_L_0.5_bin.nii.gz \
    -bin ${BASE}/roi/exclusion/sub-${s}/fornix_exclusion_half_bin.nii.gz

    fslmaths ${BASE}/roi/exclusion/sub-${s}/fornix_exclusion_half_bin.nii.gz \
    -sub ${BASE}/roi/diff_roi/sub-${s}/HPC_R_0.5_bin.nii.gz \
    -bin ${BASE}/roi/exclusion/sub-${s}/fornix_exclusion_full_bin.nii.gz

    fslmaths ${BASE}/roi/exclusion/sub-${s}/fornix_exclusion_full_bin.nii.gz \
    -ero -bin ${BASE}/roi/exclusion/sub-${s}/fornix_exclusion_bin.nii.gz

    rm -f ${BASE}/roi/exclusion/sub-${s}/fornix_exclusion_half_bin.nii.gz
    rm -f ${BASE}/roi/exclusion/sub-${s}/fornix_exclusion_full_bin.nii.gz

    fslmaths ${BASE}/roi/diff_roi/sub-${s}/HPC_L_0.5_bin.nii.gz \
    -add ${BASE}/roi/diff_roi/sub-${s}/HPC_R_0.5_bin.nii.gz \
    -add ${BASE}/roi/diff_roi/sub-${s}/amygdala_exclusion_bin.nii.gz \
    -add ${BASE}/roi/exclusion/sub-${s}/cortex_exclusion_bin.nii.gz \
    -bin ${BASE}/roi/exclusion/sub-${s}/vta_limbic_exclusion_bin.nii.gz

    fslmaths ${BASE}/roi/exclusion/sub-${s}/fornix_exclusion_bin.nii.gz \
    -add ${BASE}/roi/exclusion/sub-${s}/cortex_exclusion_bin.nii.gz \
    -add ${BASE}/roi/diff_roi/sub-${s}/amygdala_exclusion_bin.nii.gz \
    -add ${BASE}/roi/diff_roi/sub-${s}/limbic_striatum_bin.nii.gz \
    -bin ${BASE}/roi/exclusion/sub-${s}/vta_hipp_exclusion_bin.nii.gz

    echo "Finished sub-${s}"
done