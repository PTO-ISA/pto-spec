// PTO-TEST: {"id":"PTO-AVS-BLOCK-HL-QPOP-ACQUIRE-001","source":"asl/block/lifecycle/HL.QPOP.asl","requirements":["PTO-INST-BLOCK-HL-QPOP"],"kind":"execution","summary":"HL.QPOP removes the head atomically and acquires the observed release epoch","pass_condition":"a successful pop returns data and post-pop count, consumes one entry, records the matching release epoch, and broadcasts only after success","related_sources":["asl/block/model/commit/effects.asl"]}
pure func HLQPOPInstruction(destination0: Reg5Selector,
                            destination1: Reg5Selector,
                            source_left: Reg5Selector,
                            flags: bits(2)) => bits(64)
begin
    var instruction = Zeros{64} + 0x0000207d000e;
    instruction[27:23] = Zeros{5} + destination0;
    instruction[15:11] = Zeros{5} + destination1;
    instruction[35:31] = Zeros{5} + source_left;
    instruction[41] = flags[1];
    instruction[42] = flags[0];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    - = InitializeGQMQueue(Zeros{PTO_XLEN} + 0x1400, 2);
    - = PushGQMQueueEntry(Zeros{PTO_XLEN} + 0x1400,
        Zeros{PTO_XLEN} + 0x1234, FALSE, FALSE, FALSE);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x1400);

    let status = ExecuteCommandInstruction(
        HLQPOPInstruction(2, 3, 1, '10'), 48);
    assert status == CommandExecution_Executed;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0x1234;
    assert ReadGPR(3)[63:62] == '00';
    assert UInt(ReadGPR(3)[12:0]) == 0;
    assert GQMQueueRemaining(Zeros{PTO_XLEN} + 0x1400) == 2;
    assert _LastGQMAcquireEpoch == 1;
    assert _GQMEventEpoch == 1;
    return 0;
end;
