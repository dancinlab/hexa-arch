#!/usr/bin/env python3
from vina import Vina
import os, glob

RECEPTOR = "/tmp/7bw1_recep.pdbqt"
CX, CY, CZ = -30.88, 15.65, 36.45  # NDX centroid

print("=== SRD5A2 (7BW1) Vina docking — 9 ligand ===")
v = Vina(sf_name="vina", cpu=4, verbosity=0)
v.set_receptor(RECEPTOR)
v.compute_vina_maps(center=[CX, CY, CZ], box_size=[24.0, 24.0, 24.0])

results = []
for lig_path in sorted(glob.glob("/tmp/lig/*.pdbqt")):
    name = os.path.basename(lig_path).replace(".pdbqt", "")
    try:
        v.set_ligand_from_file(lig_path)
        v.dock(exhaustiveness=8, n_poses=3)
        e = v.energies(n_poses=1)
        aff = float(e[0][0]) if len(e) > 0 else None
        results.append((name, aff, "OK"))
    except Exception as ex:
        results.append((name, None, "ERR:" + type(ex).__name__))

print()
print("=" * 60)
hdr = "{:18s} {:>20s} {:>10s}".format("Compound", "BindAff (kcal/mol)", "Status")
print(hdr)
print("=" * 60)
sorted_r = sorted(results, key=lambda x: x[1] if isinstance(x[1], (int, float)) else 99)
for name, aff, st in sorted_r:
    aff_str = "{:+.2f}".format(aff) if isinstance(aff, (int, float)) else "-"
    print("{:18s} {:>20s} {:>10s}".format(name, aff_str, st))
print("=" * 60)
print("Box: center=({},{},{}) size=24A | receptor=7BW1 SRD5A2".format(CX, CY, CZ))
