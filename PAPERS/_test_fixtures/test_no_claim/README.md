# test_no_claim — fixture

Expected behavior under `PAPERS/_tools/check_rtsc_claim.sh`: **PASS silently**.

Body contains no `RTSC absorbed=true` substring. The hook is
optimistic-default and exits 0 without further work.
