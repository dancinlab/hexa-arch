#!/usr/bin/env python3
"""LENS + ECOPAD in silico — ligand 분자 특성 + Lipinski + 안전성 예측"""
from rdkit import Chem
from rdkit.Chem import AllChem, Descriptors, Lipinski

LENS_ligands = {
    "PHMB_n4 (mimic)":        "NC(=N)NCCCCCCNC(=N)NCCCCCCNC(=N)NCCCCCCNC(=N)N",
    "Polyquat-1_unit":        "C[N+](C)(C)CCCC[N+](C)(C)C.[Cl-].[Cl-]",
    "MPDA (Acanthamoeba)":    "CCCCCCCCCCCCCC(=O)NCCCN(C)C",
    "Poloxamer (PEG-PPG)":    "OCCOCCOCCOCC(C)OCC(C)OCC(C)OCCOCCOCCO",
    "EDTA":                   "OC(=O)CN(CCN(CC(=O)O)CC(=O)O)CC(=O)O",
    "alpha-Tocopherol":       "CC1=C(C)C2=C(CCC(C)(CCCC(C)CCCC(C)CCCC(C)C)O2)C(C)=C1O",
    "Hyaluronic acid (unit)": "OC1C(O)C(OC2C(NC(C)=O)C(O)OC(CO)C2O)C(C(=O)O)OC1O",
    "Citric acid":            "OC(=O)CC(O)(CC(=O)O)C(=O)O",
}

ECOPAD_ligands = {
    "Cellobiose (cellulose)": "OC[C@H]1O[C@@H](O[C@H]2[C@H](O)[C@@H](O)O[C@H](CO)[C@@H]2O)[C@H](O)[C@@H](O)[C@@H]1O",
    "Glycerin":               "OCC(O)CO",
    "CMC (mimic)":             "OC(=O)C[C@H]1O[C@H](CO)[C@@H](O)[C@H](O)[C@@H]1O",
    "Chitosan_monomer":       "OC[C@H]1O[C@H](O)[C@H](N)[C@@H](O)[C@@H]1O",
    "Lactic acid":            "CC(O)C(=O)O",
    "Citric acid (eco)":      "OC(=O)CC(O)(CC(=O)O)C(=O)O",
    "Terpinen-4-ol (tree)":   "CC(C)C1CCC(C)=CC1O",
    "Xylitol":                "OCC(O)C(O)C(O)CO",
}

def analyze(label, ligands):
    print("\n=== " + label + " ===")
    hdr = "{:24s} {:>7s} {:>6s} {:>4s} {:>4s} {:>6s} {:>5s} {:>4s}"
    print(hdr.format("Compound", "MW", "logP", "HBD", "HBA", "TPSA", "RotB", "Ro5"))
    print("-" * 72)
    fmt = "{:24s} {:7.1f} {:+6.2f} {:4d} {:4d} {:6.1f} {:5d} {:4d}"
    for name, smi in ligands.items():
        mol = Chem.MolFromSmiles(smi)
        if not mol:
            print("{:24s} SMILES FAIL".format(name)); continue
        mw = Descriptors.MolWt(mol)
        logp = Descriptors.MolLogP(mol)
        hbd = Lipinski.NumHDonors(mol)
        hba = Lipinski.NumHAcceptors(mol)
        tpsa = Descriptors.TPSA(mol)
        rotb = Lipinski.NumRotatableBonds(mol)
        ro5 = sum([mw <= 500, logp <= 5, hbd <= 5, hba <= 10])
        print(fmt.format(name, mw, logp, hbd, hba, tpsa, rotb, ro5))

analyze("QD-LENS — 보존제·세척·보습 분자 특성", LENS_ligands)
analyze("QD-ECOPAD — 흡수체·항균·약산성 분자 특성", ECOPAD_ligands)

print()
print("Ro5 = Lipinski (4=excellent · 3=moderate · <=2=poor)")
print("logP > +2 = lipophilic (피부/모낭 침투)")
print("logP < 0 = polar (수용성, 표피 침투 약, 전달체계 필요)")
print("HBD > 5 = drug-likeness 위반 (큰 분자)")
