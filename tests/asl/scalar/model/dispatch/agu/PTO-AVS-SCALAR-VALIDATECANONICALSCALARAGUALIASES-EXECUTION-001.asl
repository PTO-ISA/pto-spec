// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARAGUALIASES-EXECUTION-001","source":"asl/scalar/model/dispatch/agu.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarAGUAliases","pass_condition":"ValidateCanonicalScalarAGUAliases completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAGUAliases();
    return 0;
end;
