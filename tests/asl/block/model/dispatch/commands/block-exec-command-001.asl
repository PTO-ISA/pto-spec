// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-CMD-EXEC-001","source":"asl/block/model/dispatch/commands.asl","requirements":[],"kind":"execution","summary":"Covers Canonical Command Execution.","pass_condition":"ValidateCanonicalCommandExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalCommandExecution();
    return 0;
end;
