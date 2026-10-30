#!/bin/sh
#PBS -N hbp_tckgen
#PBS -q normal
#PBS -l walltime=96:00:00
#PBS -l nodes=1:ppn=24

cd $PBS_O_WORKDIR
module load mrtrix3/2018-10-31

SUBJECTS="10013 10016 10017 10025 10029 10033 10036 10038 10039 10041 10051 10052 10055 10060 10065 10071 10082 10110 10116 10137 10139 10143 10156 10158 10160 10163 10168 10176 10177 10186 10189 10191 10215 10217 10219 10220 10225 10229 10237 10239 10245 10248 10253 10254 10255 10272 10279 10282 10292 10299 10308 10310 10323 10324 10331 10332 10337 10341 10357 10366 10369 10376 10381 10382 10388 10391 10392 10397 10400 10404 10421 10427 10430 10442 10444 10480 10494 10513 10524 10531 10541 10552 10557 10564 10572 10573 10594 10602 10608 10623 10625 10631 10655 10666 10668 10676 10691 10692 10693 10706 10711"

for s in ${SUBJECTS}
do
    mkdir -p /home/tur31625/work/hbp/tckgen/l_vta_l_hipp/sub-${s}
    mkdir -p /home/tur31625/work/hbp/tckgen/r_vta_r_hipp/sub-${s}
    mkdir -p /home/tur31625/work/hbp/tckgen/l_vta_l_limbic/sub-${s}
    mkdir -p /home/tur31625/work/hbp/tckgen/r_vta_r_limbic/sub-${s}

    tckgen \
    /home/tur31625/work/hbp/csd/sub-${s}/wm_fod.mif \
    /home/tur31625/work/hbp/tckgen/l_vta_l_hipp/sub-${s}/sub-${s}-lvta-lhipp.tck \
    -algorithm iFOD2 \
    -seed_image /home/tur31625/work/hbp/roi/diff_roi/sub-${s}/mean_VTA_thr0.5_bin.nii.gz \
    -seed_unidirectional \
    -seeds 1380000 \
    -include /home/tur31625/work/hbp/roi/diff_roi/sub-${s}/HPC_L_0.5_bin.nii.gz \
    -exclude /home/tur31625/work/hbp/roi/exclusion/sub-${s}/T1_MNI_Rhemi_bin.nii.gz \
    -exclude /home/tur31625/work/hbp/roi/exclusion/sub-${s}/vta_hipp_exclusion_bin.nii.gz \
    -fslgrad /home/tur31625/work/hbp/eddy/sub-${s}/sub-${s}.eddy_rotated_bvecs /home/tur31625/work/hbp/nifti/dwi/sub-${s}/sub-${s}_dir-PA_dwi.bval \
    -stop -force

    tckgen \
    /home/tur31625/work/hbp/csd/sub-${s}/wm_fod.mif \
    /home/tur31625/work/hbp/tckgen/r_vta_r_hipp/sub-${s}/sub-${s}-rvta-rhipp.tck \
    -algorithm iFOD2 \
    -seed_image /home/tur31625/work/hbp/roi/diff_roi/sub-${s}/mean_VTA_thr0.5_bin.nii.gz \
    -seed_unidirectional \
    -seeds 1380000 \
    -include /home/tur31625/work/hbp/roi/diff_roi/sub-${s}/HPC_R_0.5_bin.nii.gz \
    -exclude /home/tur31625/work/hbp/roi/exclusion/sub-${s}/T1_MNI_Lhemi_bin.nii.gz \
    -exclude /home/tur31625/work/hbp/roi/exclusion/sub-${s}/vta_hipp_exclusion_bin.nii.gz \
    -fslgrad /home/tur31625/work/hbp/eddy/sub-${s}/sub-${s}.eddy_rotated_bvecs /home/tur31625/work/hbp/nifti/dwi/sub-${s}/sub-${s}_dir-PA_dwi.bval \
    -stop -force

    tckgen \
    /home/tur31625/work/hbp/csd/sub-${s}/wm_fod.mif \
    /home/tur31625/work/hbp/tckgen/l_vta_l_limbic/sub-${s}/sub-${s}-lvta-limbic.tck \
    -algorithm iFOD2 \
    -seed_image /home/tur31625/work/hbp/roi/diff_roi/sub-${s}/mean_VTA_thr0.5_bin.nii.gz \
    -seed_unidirectional \
    -seeds 1380000 \
    -include /home/tur31625/work/hbp/roi/diff_roi/sub-${s}/limbic_striatum_bin.nii.gz \
    -exclude /home/tur31625/work/hbp/roi/exclusion/sub-${s}/T1_MNI_Rhemi_bin.nii.gz \
    -exclude /home/tur31625/work/hbp/roi/exclusion/sub-${s}/vta_limbic_exclusion_bin.nii.gz \
    -fslgrad /home/tur31625/work/hbp/eddy/sub-${s}/sub-${s}.eddy_rotated_bvecs /home/tur31625/work/hbp/nifti/dwi/sub-${s}/sub-${s}_dir-PA_dwi.bval \
    -stop -force

    tckgen \
    /home/tur31625/work/hbp/csd/sub-${s}/wm_fod.mif \
    /home/tur31625/work/hbp/tckgen/r_vta_r_limbic/sub-${s}/sub-${s}-rvta-limbic.tck \
    -algorithm iFOD2 \
    -seed_image /home/tur31625/work/hbp/roi/diff_roi/sub-${s}/mean_VTA_thr0.5_bin.nii.gz \
    -seed_unidirectional \
    -seeds 1380000 \
    -include /home/tur31625/work/hbp/roi/diff_roi/sub-${s}/limbic_striatum_bin.nii.gz \
    -exclude /home/tur31625/work/hbp/roi/exclusion/sub-${s}/T1_MNI_Lhemi_bin.nii.gz \
    -exclude /home/tur31625/work/hbp/roi/exclusion/sub-${s}/vta_limbic_exclusion_bin.nii.gz \
    -fslgrad /home/tur31625/work/hbp/eddy/sub-${s}/sub-${s}.eddy_rotated_bvecs /home/tur31625/work/hbp/nifti/dwi/sub-${s}/sub-${s}_dir-PA_dwi.bval \
    -stop -force

    echo "Finished sub-${s}"
done