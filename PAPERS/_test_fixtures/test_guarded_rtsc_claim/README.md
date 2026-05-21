# test_guarded_rtsc_claim — fixture

Expected behavior under `PAPERS/_tools/check_rtsc_claim.sh`: **PASS**.

Every `RTSC absorbed=true` sentence carries an honest disclaimer
("Nb is LTS, not RTSC"). Hook should treat the claim as guarded and
exit 0 without consulting any companion attestation record.
