// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-VALIDATECANONICALSCALARSYSEFFECTS-EXECUTION-001","source":"asl/scalar/model/dispatch/sys.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalScalarSYSEffects","pass_condition":"ValidateCanonicalScalarSYSEffects completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSEffects();
    return 0;
end;
