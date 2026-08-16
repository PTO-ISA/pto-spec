// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-CMD-HEADER-001","source":"asl/block/model/dispatch/commands.asl","requirements":[],"kind":"execution","summary":"Executes every canonical block header command form.","pass_condition":"ValidateCanonicalCommandHeaderExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalCommandHeaderExecution();
    return 0;
end;
