// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARBINARYEFFECTS-EXECUTION-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarBinaryEffects","pass_condition":"ValidateCanonicalScalarBinaryEffects completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarBinaryEffects();
    return 0;
end;
