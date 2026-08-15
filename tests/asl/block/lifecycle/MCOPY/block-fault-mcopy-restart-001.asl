// PTO-TEST: {"id":"PTO-AVS-BLOCK-MCOPY-RESTART-001","source":"asl/block/lifecycle/MCOPY.asl","requirements":["PTO-INST-BLOCK-MCOPY"],"kind":"fault","summary":"MCOPY resumes at the exact faulting memory step without rereading operands or repeating committed steps","pass_condition":"one committed eight-byte step and its two events persist across a destination permission fault; recovery retries only the second step from saved operands, completes the copy, and retires once","related_sources":["asl/block/model/commit/effects.asl","asl/arch/state/trap-context.asl"]}
pure func MCOPYInstruction(destination: Reg5Selector,
                           source: Reg5Selector,
                           length: Reg5Selector) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000031;
    instruction[19:15] = Zeros{5} + destination;
    instruction[24:20] = Zeros{5} + source;
    instruction[31:27] = Zeros{5} + length;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source = Zeros{PTO_XLEN} + 0x100;
    let destination = Zeros{PTO_XLEN} + 3064;
    let instruction_pc = Zeros{PTO_XLEN} + 0x700;
    let instruction = MCOPYInstruction(2, 3, 4);
    for byte_index = 0 to 15 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        WriteMemoryByte(source + offset, Zeros{8} + byte_index + 1);
    end;
    WriteGPR(2, destination);
    WriteGPR(3, source);
    WriteGPR(4, Zeros{PTO_XLEN} + 16);
    StartMemoryEventCapture(0);
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(instruction_pc);
    ClearFault();

    let first_status = ExecuteCommandInstruction(instruction, 32);

    assert first_status == CommandExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == destination + (Zeros{PTO_XLEN} + 8);
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _MemoryEventCount == 2;
    for byte_index = 0 to 7 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        assert ReadMemoryByte(destination + offset) ==
            ReadMemoryByte(source + offset);
    end;
    for byte_index = 8 to 15 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        assert ReadMemoryByte(destination + offset) == Zeros{8};
    end;
    assert _TrapContexts[[1]].memory_copy_template.active;
    assert _TrapContexts[[1]].memory_copy_template.progress ==
        Zeros{PTO_XLEN} + 8;

    WriteGPR(2, Zeros{PTO_XLEN} + 0x20);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x40);
    WriteGPR(4, Zeros{PTO_XLEN});
    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert ReadTPC() == instruction_pc;
    SetCurrentACR(0);
    ClearFault();

    let second_status = ExecuteCommandInstruction(instruction, 32);

    assert second_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert _MemoryEventCount == 4;
    for byte_index = 0 to 15 do
        let offset = NaturalToWord(byte_index as integer {0..262144});
        assert ReadMemoryByte(destination + offset) ==
            ReadMemoryByte(source + offset);
    end;
    assert !_MemoryCopyTemplate.active;
    assert _LastMemoryCommandAddress == destination;
    assert _LastMemoryCommandSize == Zeros{PTO_XLEN} + 16;
    assert ReadTPC() == instruction_pc + (Zeros{PTO_XLEN} + 4);
    return 0;
end;
