// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSSWAPALIASES0TO7-EXECUTION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSSwapAliases0To7","pass_condition":"ValidateCanonicalScalarSYSSwapAliases0To7 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSwapAliases0To7();
    return 0;
end;
