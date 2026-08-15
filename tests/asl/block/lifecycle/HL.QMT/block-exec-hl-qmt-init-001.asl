// PTO-TEST: {"id":"PTO-AVS-BLOCK-HL-QMT-INIT-001","source":"asl/block/lifecycle/HL.QMT.asl","requirements":["PTO-INST-BLOCK-HL-QMT"],"kind":"execution","summary":"HL.QMT initialization replaces queue state and a bare query reports remaining entries","pass_condition":"capacity three initializes a valid empty writable queue, returns 24 allocated bytes, and the following query returns three remaining entries","related_sources":["asl/block/model/commit/effects.asl"]}
pure func HLQMTInstruction(destination: Reg5Selector,
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
    WriteTPC(Zeros{PTO_XLEN} + 0x700);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x1000);
    WriteGPR(2, Zeros{PTO_XLEN} + 3);

    let initialize = ExecuteCommandInstruction(
        HLQMTInstruction(3, 1, 2, '1000'), 48);
    assert initialize == CommandExecution_Executed;
    assert ReadGPR(3)[63:62] == '00';
    assert UInt(ReadGPR(3)[12:0]) == 24;
    assert GQMQueueInitialized(Zeros{PTO_XLEN} + 0x1000);
    assert GQMQueueRemaining(Zeros{PTO_XLEN} + 0x1000) == 3;
    assert !GQMQueueSuspended(Zeros{PTO_XLEN} + 0x1000);

    let query = ExecuteCommandInstruction(
        HLQMTInstruction(4, 1, 0, '0000'), 48);
    assert query == CommandExecution_Executed;
    assert ReadGPR(4)[63:62] == '00';
    assert UInt(ReadGPR(4)[12:0]) == 3;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x70c;
    return 0;
end;
