// PTO-TEST: {"id":"PTO-AVS-BLOCK-FEXIT-RESTART-001","source":"asl/block/lifecycle/FEXIT.asl","requirements":["PTO-INST-BLOCK-FEXIT"],"kind":"fault","summary":"FEXIT restarts at the exact first uncommitted load without adding sp twice","pass_condition":"a page fault preserves adjusted sp and zero progress in trap context; recovery under an accessible ring restores the saved frame and completes once","related_sources":["asl/block/model/lifecycle/lifetime.asl","asl/arch/state/trap-context.asl"]}
pure func FEXITInstruction(begin_reg: Reg5Selector,
                           end_reg: Reg5Selector,
                           size: Word) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001041;
    instruction[19:15] = Zeros{5} + begin_reg;
    instruction[24:20] = Zeros{5} + end_reg;
    instruction[31:25] = size[9:3];
    instruction[11:7] = size[14:10];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let instruction_pc = Zeros{PTO_XLEN} + 0x5c0;
    WriteMemoryByte(Zeros{PTO_XLEN} + 3072, Zeros{8} + 0x77);
    WriteGPR(1, Zeros{PTO_XLEN} + 3072);
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(instruction_pc);
    ClearFault();

    let instruction = FEXITInstruction(3, 3, Zeros{PTO_XLEN} + 8);
    let first_status = ExecuteCommandInstruction(instruction, 32);

    assert first_status == CommandExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 3080;
    assert _TrapContexts[[1]].frame_template.active;
    assert _TrapContexts[[1]].frame_template.stack_adjusted;
    assert _TrapContexts[[1]].frame_template.progress == 0;

    let recovered = RecoverTrapContext(1);
    assert recovered;
    SetCurrentACR(0);
    ClearFault();
    let second_status = ExecuteCommandInstruction(instruction, 32);

    assert second_status == CommandExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 3080;
    assert ReadGPR(3)[7:0] == Zeros{8} + 0x77;
    assert !_FrameTemplate.active;
    assert ReadTPC() == instruction_pc + (Zeros{PTO_XLEN} + 4);
    return 0;
end;
