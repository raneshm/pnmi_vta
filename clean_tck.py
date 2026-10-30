import numpy as np
import os
from dipy.io.streamline import load_tck, save_tck
from dipy.io.stateful_tractogram import StatefulTractogram
from dipy.tracking.streamline import orient_by_streamline, set_number_of_points
from dipy.segment.clustering import QuickBundles
from dipy.segment.metricspeed import AveragePointwiseEuclideanMetric
from dipy.segment.featurespeed import ResampleFeature

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

def clean_mahalanobis(streamlines, threshold=3, iterations=5):
    centroid = QuickBundles(np.inf, metric=metric).cluster(streamlines).centroids[0]
    streamlines = list(orient_by_streamline(streamlines, centroid))

    for _ in range(iterations):
        if len(streamlines) < 4:
            break

        pts = np.array([set_number_of_points(sl, 100) for sl in streamlines])
        dist = np.zeros((len(streamlines), 100))

        for node in range(100):
            x = pts[:, node, :]
            diff = x - x.mean(axis=0)
            inv_cov = np.linalg.pinv(np.cov(x, rowvar=False))
            dist[:, node] = np.sqrt(np.einsum("ij,jk,ik->i", diff, inv_cov, diff))

        score = dist.mean(axis=1)
        keep = score <= score.mean() + threshold * score.std(ddof=1)

        if keep.all():
            break

        streamlines = [sl for sl, k in zip(streamlines, keep) if k]

    return streamlines

for s in SUBJECTS:
    ref = f"{BASE}/NODDI_new/sub-{s}/sub-{s}.nii.gz"

    for tract in TRACTS:
        node_dir = f"{BASE}/tckgen/{tract}/sub-{s}/nodewise"
        infile = f"{node_dir}/{tract}.tck"
        outfile = f"{node_dir}/{tract}_cleaned.tck"

        if not os.path.exists(infile) or not os.path.exists(ref):
            print(f"Missing sub-{s} {tract}")
            continue

        sft = load_tck(infile, ref, bbox_valid_check=False)
        n_before = len(sft.streamlines)

        cleaned = clean_mahalanobis(list(sft.streamlines))
        out_sft = StatefulTractogram.from_sft(cleaned, sft)
        save_tck(out_sft, outfile, bbox_valid_check=False)

        print(f"sub-{s} {tract}: {n_before} -> {len(cleaned)}")