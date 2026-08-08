// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSSWAPALIASES16TO23-EXECUTION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSSwapAliases16To23","pass_condition":"ValidateCanonicalScalarSYSSwapAliases16To23 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSwapAliases16To23();
    return 0;
end;
