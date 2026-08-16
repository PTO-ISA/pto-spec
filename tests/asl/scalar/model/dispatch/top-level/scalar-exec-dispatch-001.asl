// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-ALU-CANON-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Executes every canonical ALU form independently from reset state.","pass_condition":"ValidateCanonicalScalarALUExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarALUExecution();
    return 0;
end;
