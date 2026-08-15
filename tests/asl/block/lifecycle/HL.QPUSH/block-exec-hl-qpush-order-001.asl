// PTO-TEST: {"id":"PTO-AVS-BLOCK-HL-QPUSH-ORDER-001","source":"asl/block/lifecycle/HL.QPUSH.asl","requirements":["PTO-INST-BLOCK-HL-QPUSH"],"kind":"execution","summary":"HL.QPUSH appends at the tail or inserts at the head atomically","pass_condition":"tail then head pushes leave the head value first, return the post-push remaining capacity, and assign release epochs to both entries","related_sources":["asl/block/model/commit/effects.asl"]}
pure func HLQPUSHInstruction(destination: Reg5Selector,
                             source_left: Reg5Selector,
                             source_right: Reg5Selector,
                             flags: bits(3)) => bits(64)
begin
    var instruction = Zeros{64} + 0x0000107d000e;
    instruction[27:23] = Zeros{5} + destination;
    instruction[35:31] = Zeros{5} + source_left;
    instruction[40:36] = Zeros{5} + source_right;
    instruction[43] = flags[2];
    instruction[41] = flags[1];
    instruction[42] = flags[0];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    - = InitializeGQMQueue(Zeros{PTO_XLEN} + 0x1200, 3);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x1200);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x11);

    let tail = ExecuteCommandInstruction(
        HLQPUSHInstruction(3, 1, 2, '000'), 48);
    assert tail == CommandExecution_Executed;
    assert ReadGPR(3)[63:62] == '00';
    assert UInt(ReadGPR(3)[9:0]) == 2;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x22);
    let head = ExecuteCommandInstruction(
        HLQPUSHInstruction(4, 1, 2, '100'), 48);
    assert head == CommandExecution_Executed;
    assert UInt(ReadGPR(4)[9:0]) == 1;
    assert GQMQueueHeadValue(Zeros{PTO_XLEN} + 0x1200) ==
        Zeros{PTO_XLEN} + 0x22;
    assert GQMQueueHeadReleaseEpoch(Zeros{PTO_XLEN} + 0x1200) == 2;
    return 0;
end;
