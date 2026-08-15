// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-SWAP-ALIAS-16-23-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"Covers Canonical Scalar SYS Swap Aliases16 To23.","pass_condition":"ValidateCanonicalScalarSYSSwapAliases16To23 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSwapAliases16To23();
    return 0;
end;
