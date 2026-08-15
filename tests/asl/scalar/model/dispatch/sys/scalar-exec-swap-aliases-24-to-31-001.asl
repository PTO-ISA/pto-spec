// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-SWAP-ALIAS-24-31-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"Covers Canonical Scalar SYS Swap Aliases24 To31.","pass_condition":"ValidateCanonicalScalarSYSSwapAliases24To31 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSwapAliases24To31();
    return 0;
end;
