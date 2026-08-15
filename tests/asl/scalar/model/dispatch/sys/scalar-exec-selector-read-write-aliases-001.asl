// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-RW-ALIASES-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"Covers Canonical Scalar SYS Selector Read Write Aliases.","pass_condition":"ValidateCanonicalScalarSYSSelectorReadWriteAliases completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSelectorReadWriteAliases();
    return 0;
end;
