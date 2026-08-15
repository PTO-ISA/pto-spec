// PTO-TEST: {"id":"PTO-AVS-BLOCK-HL-QMT-CONTROL-001","source":"asl/block/lifecycle/HL.QMT.asl","requirements":["PTO-INST-BLOCK-HL-QMT"],"kind":"state-transition","summary":"HL.QMT orders initialization, event notification, suspension, and restoration","pass_condition":"combined initialize-event-suspend publishes one event after replacement, restore makes the queue writable, and a missing queue reports status one without event or creation","related_sources":["asl/block/model/commit/effects.asl"]}
pure func HLQMTControlInstruction(destination: Reg5Selector,
                                  source_left: Reg5Selector,
                                  source_right: Reg5Selector,
                                  flags: bits(4)) => bits(64)
begin
    var instruction = Zeros{64} + 0x0000007d000e;
    instruction[27:23] = Zeros{5} + destination;
    instruction[35:31] = Zeros{5} + source_left;
    instruction[40:36] = Zeros{5} + source_right;
    instruction[44] = flags[3];
    instruction[41] = flags[2];
    instruction[43] = flags[1];
    instruction[42] = flags[0];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x1100);
    WriteGPR(2, Zeros{PTO_XLEN} + 2);

    let initialize = ExecuteCommandInstruction(
        HLQMTControlInstruction(3, 1, 2, '1110'), 48);
    assert initialize == CommandExecution_Executed;
    assert ReadGPR(3)[63:62] == '00';
    assert GQMQueueSuspended(Zeros{PTO_XLEN} + 0x1100);
    assert _GQMEventEpoch == 1;
    assert _LastGQMEventAddress == Zeros{PTO_XLEN} + 0x1100;

    let restore = ExecuteCommandInstruction(
        HLQMTControlInstruction(4, 1, 0, '0001'), 48);
    assert restore == CommandExecution_Executed;
    assert !GQMQueueSuspended(Zeros{PTO_XLEN} + 0x1100);

    WriteGPR(1, Zeros{PTO_XLEN} + 0x2200);
    let missing = ExecuteCommandInstruction(
        HLQMTControlInstruction(5, 1, 0, '0100'), 48);
    assert missing == CommandExecution_Executed;
    assert ReadGPR(5)[63:62] == '01';
    assert UInt(ReadGPR(5)[12:0]) == 0;
    assert !GQMQueueInitialized(Zeros{PTO_XLEN} + 0x2200);
    assert _GQMEventEpoch == 1;
    return 0;
end;
