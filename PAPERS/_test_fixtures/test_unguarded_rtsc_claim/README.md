# test_unguarded_rtsc_claim — fixture

Expected behavior under `PAPERS/_tools/check_rtsc_claim.sh`: **FAIL**.

Abstract makes a bare `RTSC absorbed=true` claim with no LTS/HTS/NOT-RTSC
disclaimer. README does not reference any companion attestation record, so
the hook must exit non-zero with "cannot locate companion attestation record".
