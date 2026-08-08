// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSSWAPALIASES24TO31-EXECUTION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSSwapAliases24To31","pass_condition":"ValidateCanonicalScalarSYSSwapAliases24To31 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSwapAliases24To31();
    return 0;
end;
