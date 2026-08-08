// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARFSUEFFECTS-EXECUTION-001","source":"asl/scalar/model/dispatch/fsu.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarFSUEffects","pass_condition":"ValidateCanonicalScalarFSUEffects completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarFSUEffects();
    return 0;
end;
