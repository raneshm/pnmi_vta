import amico
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

BASE = "/Volumes/psychology/Ellman_Group/Healthy_Brains_Project/Data/HBP_Data/MRI/derivatives/RM_ClusterBackup/DWI/hbp"
OUT = os.path.join(BASE, "NODDI_new")
os.makedirs(OUT, exist_ok=True)
os.chdir(OUT)
amico.setup()

regenerate = True

for s in SUBJECTS:
    sub = f"sub-{s}"
    noddi = os.path.join(OUT, sub)
    os.makedirs(noddi, exist_ok=True)

    try:
        bval = os.path.join(BASE, "nifti", "dwi", sub, f"{sub}_dir-PA_dwi.bval")
        bvec = os.path.join(BASE, "eddy", sub, f"{sub}.eddy_rotated_bvecs")
        scheme = os.path.join(noddi, f"{sub}.scheme")
        dwi = os.path.join(noddi, f"{sub}.nii.gz")
        mask = os.path.join(noddi, f"{sub}_skullstripped_mask.nii.gz")

        amico.util.fsl2scheme(bval, bvec, scheme)

        ae = amico.Evaluation(OUT, sub, noddi)
        ae.load_data(dwi, scheme, mask, b0_thr=20)
        ae.set_model("NODDI")
        ae.model.dPar = 1.7e-3
        ae.set_config("doSaveModulatedMaps", True)

        ae.generate_kernels(regenerate=regenerate)
        regenerate = False
        ae.load_kernels()
        ae.fit()
        ae.save_results()

        print(f"Finished {sub}")

    except Exception as e:
        print(f"ERROR {sub}: {e}")