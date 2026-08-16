// PTO-TEST: {"id":"PTO-AVS-SCALAR-AMO-CANON-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Executes every canonical AMO form independently from reset state.","pass_condition":"ValidateCanonicalScalarAMOExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarAMOExecution();
    return 0;
end;
