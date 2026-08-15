// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-SWAP-ALIAS-0-7-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"Covers Canonical Scalar SYS Swap Aliases0 To7.","pass_condition":"ValidateCanonicalScalarSYSSwapAliases0To7 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSwapAliases0To7();
    return 0;
end;
