// PTO-TEST: {"id":"PTO-AVS-MSGB-RESET-001","source":"asl/arch/state/message-buffer-state.asl","requirements":["PTO-ARCH-MSGB-STATE-001"],"kind":"state-transition","summary":"Cold initialization establishes empty disabled message banks","pass_condition":"all message banks and persistent result fields have their specified reset state","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    assert MessageBufferStateIsReset();
    assert MessageBufferCoreQuiescent(0);
    assert MessageBufferCoreQuiescent(1);
    return 0;
end;
