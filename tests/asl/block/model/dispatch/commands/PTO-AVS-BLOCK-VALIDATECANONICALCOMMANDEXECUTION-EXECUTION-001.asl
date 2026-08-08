// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-VALIDATECANONICALCOMMANDEXECUTION-EXECUTION-001","source":"asl/block/model/dispatch/commands.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for ValidateCanonicalCommandExecution","pass_condition":"ValidateCanonicalCommandExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalCommandExecution();
    return 0;
end;
