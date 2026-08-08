// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARBRUEFFECTS-EXECUTION-001","source":"asl/scalar/model/dispatch/bru.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarBRUEffects","pass_condition":"ValidateCanonicalScalarBRUEffects completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarBRUEffects();
    return 0;
end;
