// PTO-TEST: {"id":"PTO-AVS-SCALAR-SYS-CANON-001","source":"asl/scalar/model/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Executes every canonical SYS form in its required block context.","pass_condition":"ValidateCanonicalScalarSYSExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalScalarSYSExecution();
    return 0;
end;
