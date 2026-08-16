// PTO-TEST: {"id":"PTO-AVS-SCALAR-FSU-CANON-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Executes every canonical FSU form independently from reset state.","pass_condition":"ValidateCanonicalScalarFSUExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarFSUExecution();
    return 0;
end;
