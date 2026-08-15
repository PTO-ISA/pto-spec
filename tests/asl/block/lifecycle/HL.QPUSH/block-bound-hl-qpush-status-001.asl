// PTO-TEST: {"id":"PTO-AVS-BLOCK-HL-QPUSH-STATUS-001","source":"asl/block/lifecycle/HL.QPUSH.asl","requirements":["PTO-INST-BLOCK-HL-QPUSH"],"kind":"boundary","summary":"HL.QPUSH reports full, suspended, missing, and corrupt queue states without mutation or event","pass_condition":"full and suspended return status one, missing and corrupt return status two, and every failed attempt preserves entries, count, event epoch, and release epoch","related_sources":["asl/block/model/commit/effects.asl"]}
func main() => integer
begin
    ResetProfileState();
    - = InitializeGQMQueue(Zeros{PTO_XLEN} + 0x1300, 1);
    - = PushGQMQueueEntry(Zeros{PTO_XLEN} + 0x1300,
        Zeros{PTO_XLEN} + 0xaa, FALSE, FALSE, FALSE);
    let before_release = _GQMReleaseEpoch;
    let before_events = _GQMEventEpoch;

    let full = PushGQMQueueEntry(Zeros{PTO_XLEN} + 0x1300,
        Zeros{PTO_XLEN} + 0xbb, FALSE, FALSE, TRUE);
    assert full[63:62] == '01';
    assert GQMQueueHeadValue(Zeros{PTO_XLEN} + 0x1300) ==
        Zeros{PTO_XLEN} + 0xaa;

    SetGQMQueueSuspended(Zeros{PTO_XLEN} + 0x1300, TRUE);
    let suspended = PushGQMQueueEntry(Zeros{PTO_XLEN} + 0x1300,
        Zeros{PTO_XLEN} + 0xcc, FALSE, FALSE, TRUE);
    assert suspended[63:62] == '01';
    let missing = PushGQMQueueEntry(Zeros{PTO_XLEN} + 0x2300,
        Zeros{PTO_XLEN} + 0xdd, FALSE, FALSE, TRUE);
    assert missing[63:62] == '10';
    SetGQMQueueCorrupt(Zeros{PTO_XLEN} + 0x1300, TRUE);
    let corrupt = PushGQMQueueEntry(Zeros{PTO_XLEN} + 0x1300,
        Zeros{PTO_XLEN} + 0xee, FALSE, FALSE, TRUE);
    assert corrupt[63:62] == '10';
    assert _GQMReleaseEpoch == before_release;
    assert _GQMEventEpoch == before_events;
    return 0;
end;
