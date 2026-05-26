#!/usr/bin/env python3
"""SRD5A2 (7BW1) Vina docking — Phase 2 receptor prep + 9 ligand binding affinity"""
import os, subprocess, sys, glob

PDB = "/tmp/7BW1.pdb"
if not os.path.exists(PDB):
    PDB = "/tmp/7bw1.pdb"
CLEAN_PDB = "/tmp/7bw1_clean.pdb"

with open(PDB) as f:
    lines = f.readlines()

# Exclude buffer/detergent — NDX is the NADP-Finasteride adduct (active site)
EXCLUDED = {"HOH", "WAT", "OLC", "SO4", "PO4", "CL", "NA", "MG", "ZN", "CA"}

het_atoms_by_code = {}
for l in lines:
    if l.startswith("HETATM"):
        code = l[17:20].strip()
        if code in EXCLUDED:
            continue
        x, y, z = float(l[30:38]), float(l[38:46]), float(l[46:54])
        het_atoms_by_code.setdefault(code, []).append((x, y, z))

print("Active-site HET candidates:", {k: len(v) for k, v in het_atoms_by_code.items()})
if not het_atoms_by_code:
    print("ERROR: no active-site HET found"); sys.exit(1)

main_code = max(het_atoms_by_code.keys(), key=lambda k: len(het_atoms_by_code[k]))
coords = het_atoms_by_code[main_code]
cx = sum(c[0] for c in coords) / len(coords)
cy = sum(c[1] for c in coords) / len(coords)
cz = sum(c[2] for c in coords) / len(coords)
print(f"Box center (HET {main_code}, {len(coords)} atoms): ({cx:.2f}, {cy:.2f}, {cz:.2f})")

# Clean receptor: ATOM + TER only
with open(CLEAN_PDB, "w") as f:
    for l in lines:
        if l.startswith("ATOM") or l.startswith("TER"):
            f.write(l)
    f.write("END\n")
print(f"Cleaned receptor: {CLEAN_PDB} ({sum(1 for l in open(CLEAN_PDB) if l.startswith('ATOM'))} ATOM lines)")

# Receptor prep via Meeko CLI
RECEPTOR_OUT_BASE = "/tmp/7bw1_receptor"
r = subprocess.run(
    ["mk_prepare_receptor.py", "--read_pdb", CLEAN_PDB, "-o", RECEPTOR_OUT_BASE, "-p"],
    capture_output=True, text=True, timeout=300
)
print(f"mk_prepare_receptor rc={r.returncode}")
if r.stderr: print("stderr (tail):", r.stderr[-500:])

receptor_pdbqt = None
for cand in glob.glob(f"{RECEPTOR_OUT_BASE}*.pdbqt"):
    receptor_pdbqt = cand; break
if not receptor_pdbqt:
    # try named differently
    for cand in glob.glob("/tmp/*receptor*.pdbqt") + glob.glob("/tmp/*7bw1*.pdbqt"):
        if cand != CLEAN_PDB and cand.endswith(".pdbqt"):
            receptor_pdbqt = cand; break

if not receptor_pdbqt:
    print("Receptor PDBQT not generated. Phase 2 docking blocked.")
    sys.exit(3)

print(f"Using receptor PDBQT: {receptor_pdbqt} ({os.path.getsize(receptor_pdbqt)} bytes)")

# Run Vina docking
from vina import Vina
print("\n=== Vina docking start ===")
v = Vina(sf_name="vina", cpu=4, verbosity=0)
v.set_receptor(receptor_pdbqt)
v.compute_vina_maps(center=[cx, cy, cz], box_size=[24.0, 24.0, 24.0])
print("Vina maps computed.")

ligands_order = ["Finasteride", "Dutasteride", "L-Menthol", "SalicylicAcid",
                 "Caffeine", "Biotin", "Niacinamide", "Dexpanthenol",
                 "Adenosine", "Procapil"]

results = []
for lig_name in ligands_order:
    slug_candidates = [
        lig_name, lig_name.replace("-", ""),
        lig_name.split()[0], lig_name.split()[0].replace("-", ""),
        "L"
    ]
    lig_path = None
    for s in slug_candidates:
        p = f"/tmp/lig/{s}.pdbqt"
        if os.path.exists(p):
            lig_path = p; break
    if not lig_path:
        # try by listing dir
        for f in glob.glob("/tmp/lig/*.pdbqt"):
            base = os.path.basename(f).replace(".pdbqt", "")
            if base.lower().startswith(lig_name.split()[0].lower()[:4]):
                lig_path = f; break
    if not lig_path:
        results.append((lig_name, None, "FILE_MISSING")); continue

    try:
        v.set_ligand_from_file(lig_path)
        v.dock(exhaustiveness=8, n_poses=3)
        energies = v.energies(n_poses=1)
        aff = float(energies[0][0]) if len(energies) > 0 else None
        results.append((lig_name, aff, "OK" if aff is not None else "NO_POSE"))
    except Exception as e:
        results.append((lig_name, None, f"ERR:{type(e).__name__}"))

print()
print("=" * 64)
print(f"{'Compound':22s} {'BindAff (kcal/mol)':>20s} {'Status':>14s}")
print("=" * 64)
sorted_r = sorted(results, key=lambda x: x[1] if isinstance(x[1], (int, float)) else 99)
for name, aff, st in sorted_r:
    aff_str = f"{aff:+.2f}" if isinstance(aff, (int, float)) else "—"
    print(f"{name:22s} {aff_str:>20s} {st:>14s}")
print("=" * 64)
print(f"Box: center=({cx:.2f},{cy:.2f},{cz:.2f}) size=24Å · receptor=7BW1 SRD5A2")
print(f"Ranking: most negative = strongest 5αR-II binding")
