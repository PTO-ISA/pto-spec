// PTO-TEST: {"id":"PTO-AVS-ARCH-GQM-RESET-001","source":"asl/arch/programming-model/general-queue-management.asl","requirements":["PTO-ARCH-STATE-CLOSURE-001"],"kind":"state-transition","summary":"profile reset clears all executable GQM backing and synchronization state","pass_condition":"no queue remains initialized and all release, acquire, and event epochs return to zero","related_sources":["asl/arch/profile/reset.asl"]}
func main() => integer
begin
    ResetProfileState();
    - = InitializeGQMQueue(Zeros{PTO_XLEN} + 0x1000, 2);
    - = PushGQMQueueEntry(Zeros{PTO_XLEN} + 0x1000,
        Zeros{PTO_XLEN} + 0x55, FALSE, FALSE, TRUE);
    assert GQMQueueInitialized(Zeros{PTO_XLEN} + 0x1000);

    ResetProfileState();
    assert !GQMQueueInitialized(Zeros{PTO_XLEN} + 0x1000);
    assert _GQMReleaseEpoch == 0;
    assert _LastGQMAcquireEpoch == 0;
    assert _GQMEventEpoch == 0;
    assert _LastGQMEventAddress == Zeros{PTO_XLEN};
    return 0;
end;
