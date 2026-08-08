// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARAMOALIASES-EXECUTION-001","source":"asl/scalar/model/dispatch/amo.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarAMOAliases","pass_condition":"ValidateCanonicalScalarAMOAliases completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAMOAliases();
    return 0;
end;
