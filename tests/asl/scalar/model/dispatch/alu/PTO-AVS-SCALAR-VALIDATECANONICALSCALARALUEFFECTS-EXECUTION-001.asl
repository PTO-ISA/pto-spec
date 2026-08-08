// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARALUEFFECTS-EXECUTION-001","source":"asl/scalar/model/dispatch/alu.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarALUEffects","pass_condition":"ValidateCanonicalScalarALUEffects completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarALUEffects();
    return 0;
end;
