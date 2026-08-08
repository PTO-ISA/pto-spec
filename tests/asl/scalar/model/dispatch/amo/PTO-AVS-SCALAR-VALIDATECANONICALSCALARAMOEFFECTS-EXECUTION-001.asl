// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARAMOEFFECTS-EXECUTION-001","source":"asl/scalar/model/dispatch/amo.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarAMOEffects","pass_condition":"ValidateCanonicalScalarAMOEffects completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAMOEffects();
    return 0;
end;
