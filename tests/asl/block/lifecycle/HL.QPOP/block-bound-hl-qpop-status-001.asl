// PTO-TEST: {"id":"PTO-AVS-BLOCK-HL-QPOP-STATUS-001","source":"asl/block/lifecycle/HL.QPOP.asl","requirements":["PTO-INST-BLOCK-HL-QPOP"],"kind":"boundary","summary":"HL.QPOP distinguishes empty from missing or corrupt queues without mutation","pass_condition":"empty returns status one, missing and corrupt return status two, every data result is zero, and no failed attempt broadcasts or acquires","related_sources":["asl/block/model/commit/effects.asl"]}
func main() => integer
begin
    ResetProfileState();
    - = InitializeGQMQueue(Zeros{PTO_XLEN} + 0x1500, 0);
    let empty = PopGQMQueueEntry(
        Zeros{PTO_XLEN} + 0x1500, FALSE, TRUE);
    assert empty.data == Zeros{PTO_XLEN};
    assert empty.result[63:62] == '01';

    let missing = PopGQMQueueEntry(
        Zeros{PTO_XLEN} + 0x2500, FALSE, TRUE);
    assert missing.data == Zeros{PTO_XLEN};
    assert missing.result[63:62] == '10';

    SetGQMQueueCorrupt(Zeros{PTO_XLEN} + 0x1500, TRUE);
    let corrupt = PopGQMQueueEntry(
        Zeros{PTO_XLEN} + 0x1500, FALSE, TRUE);
    assert corrupt.data == Zeros{PTO_XLEN};
    assert corrupt.result[63:62] == '10';
    assert _LastGQMAcquireEpoch == 0;
    assert _GQMEventEpoch == 0;
    return 0;
end;
