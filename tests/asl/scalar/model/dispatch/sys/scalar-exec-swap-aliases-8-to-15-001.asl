// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-SWAP-ALIAS-8-15-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"Covers Canonical Scalar SYS Swap Aliases8 To15.","pass_condition":"ValidateCanonicalScalarSYSSwapAliases8To15 completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSwapAliases8To15();
    return 0;
end;
