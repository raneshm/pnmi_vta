import dipy.stats.analysis as dsa
import dipy.tracking.streamline as dts
from dipy.segment.clustering import QuickBundles
from dipy.segment.metricspeed import AveragePointwiseEuclideanMetric
from dipy.segment.featurespeed import ResampleFeature
from dipy.io.streamline import load_tck
from dipy.io.image import load_nifti
import matplotlib.pyplot as plt
import numpy as np
import csv
import os

SUBJECTS = list(map(int, """
10013 10016 10017 10025 10029 10033 10036 10038 10039 10041 10051 10052
10055 10060 10065 10071 10082 10110 10116 10137 10139 10143 10156 10158
10160 10163 10168 10176 10177 10186 10189 10191 10215 10217 10219 10220
10225 10229 10237 10239 10245 10248 10253 10254 10255 10272 10279 10282
10292 10299 10308 10310 10323 10324 10331 10332 10337 10341 10357 10366
10369 10376 10381 10382 10388 10391 10392 10397 10400 10404 10421 10427
10430 10442 10444 10480 10494 10513 10524 10531 10541 10552 10557 10564
10572 10573 10594 10602 10608 10623 10625 10631 10655 10666 10668 10676
10691 10692 10693 10706 10711
""".split()))

TRACTS = ["l_vta_l_hipp", "r_vta_r_hipp", "l_vta_l_limbic", "r_vta_r_limbic"]
BASE = "/Volumes/psychology/Ellman_Group/Healthy_Brains_Project/Data/HBP_Data/MRI/derivatives/RM_ClusterBackup/DWI/hbp"

feature = ResampleFeature(nb_points=100)
metric = AveragePointwiseEuclideanMetric(feature)

for s in SUBJECTS:
    ndi_file = f"{BASE}/NODDI_new/sub-{s}/fit_NDI_modulated.nii.gz"
    if not os.path.exists(ndi_file):
        print(f"Missing NDI: sub-{s}")
        continue

    ndi, affine = load_nifti(ndi_file)

    for tract in TRACTS:
        node_dir = f"{BASE}/tckgen/{tract}/sub-{s}/nodewise"
        tck_file = f"{node_dir}/{tract}_cleaned.tck"

        if not os.path.exists(tck_file):
            print(f"Missing: {tck_file}")
            continue

        streamlines = load_tck(tck_file, ndi_file, bbox_valid_check=False).streamlines
        if len(streamlines) == 0:
            continue

        centroid = QuickBundles(np.inf, metric=metric).cluster(streamlines).centroids[0]
        streamlines = dts.orient_by_streamline(streamlines, centroid)

        weights = dsa.gaussian_weights(streamlines)
        profile = dsa.afq_profile(ndi, streamlines, affine, weights=weights, n_points=100)

        fig, ax = plt.subplots()
        ax.plot(profile)
        ax.set(xlabel=f"Node along {tract}", ylabel="Neurite Density Index")
        fig.savefig(f"{node_dir}/{tract}_profile.png", dpi=300, bbox_inches="tight")
        plt.close(fig)

        with open(f"{node_dir}/{tract}_ndi_profile.csv", "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["Subject", "Node", "NDI_Value"])
            for node, value in enumerate(profile):
                writer.writerow([f"sub-{s}", node, value])

        print(f"Finished sub-{s} {tract}")