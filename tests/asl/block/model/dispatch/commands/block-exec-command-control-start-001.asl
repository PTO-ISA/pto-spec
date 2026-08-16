// PTO-TEST: {"id":"PTO-AVS-BLOCK-CMD-CTRLSTART-001","source":"asl/block/model/dispatch/commands.asl","requirements":[],"kind":"execution","summary":"Executes canonical control-flow BSTART forms.","pass_condition":"ValidateCanonicalCommandControlStartExecution completes without assertion failure","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ValidateCanonicalCommandControlStartExecution();
    return 0;
end;
