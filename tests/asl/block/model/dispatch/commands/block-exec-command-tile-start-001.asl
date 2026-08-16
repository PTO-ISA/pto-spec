// PTO-TEST: {"id":"PTO-AVS-BLOCK-CMD-TILESTART-001","source":"asl/block/model/dispatch/commands.asl","requirements":[],"kind":"execution","summary":"Executes canonical tile-engine BSTART forms and selector variants.","pass_condition":"ValidateCanonicalCommandTileStartExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalCommandTileStartExecution();
    return 0;
end;
