// PTO-TEST: {"id":"PTO-AVS-BLOCK-HL-QMT-FLAGS-001","source":"asl/block/lifecycle/HL.QMT.asl","requirements":["PTO-INST-BLOCK-HL-QMT"],"kind":"fault","summary":"HL.QMT rejects simultaneous suspend and restore before operand or queue effects","pass_condition":"s+r raises Fault_IllegalInstruction, preserves unavailable relative sources, queue state, destinations, events, and TPC","related_sources":["asl/block/model/dispatch/commands.asl"]}
pure func HLQMTFaultInstruction(destination: Reg5Selector,
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
    WriteTPC(Zeros{PTO_XLEN} + 0x740);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x55);

    let status = ExecuteCommandInstruction(
        HLQMTFaultInstruction(3, 24, 25, '0011'), 48);

    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x55;
    assert _GQMEventEpoch == 0;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x740;
    return 0;
end;
