// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSSELECTORREADWRITEALIASES-EXECUTION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSSelectorReadWriteAliases","pass_condition":"ValidateCanonicalScalarSYSSelectorReadWriteAliases completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSSelectorReadWriteAliases();
    return 0;
end;
