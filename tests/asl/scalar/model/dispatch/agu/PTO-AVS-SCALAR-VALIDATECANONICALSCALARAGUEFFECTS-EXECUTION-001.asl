// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARAGUEFFECTS-EXECUTION-001","source":"asl/scalar/model/dispatch/agu.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarAGUEffects","pass_condition":"ValidateCanonicalScalarAGUEffects completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAGUEffects();
    return 0;
end;
