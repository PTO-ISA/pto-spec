// PTO-TEST: {"id":"PTO-AVS-SCALAR-BRU-CANON-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Executes every canonical BRU form independently from reset state.","pass_condition":"ValidateCanonicalScalarBRUExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarBRUExecution();
    return 0;
end;
