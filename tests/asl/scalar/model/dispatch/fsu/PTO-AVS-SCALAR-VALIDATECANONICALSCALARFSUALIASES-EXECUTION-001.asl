// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARFSUALIASES-EXECUTION-001","source":"asl/scalar/model/dispatch/fsu.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarFSUAliases","pass_condition":"ValidateCanonicalScalarFSUAliases completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarFSUAliases();
    return 0;
end;
