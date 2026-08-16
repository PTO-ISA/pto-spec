// PTO-TEST: {"id":"PTO-AVS-SCALAR-AGU-CANON-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Executes every canonical AGU form independently from reset state.","pass_condition":"ValidateCanonicalScalarAGUExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAGUExecution();
    return 0;
end;
