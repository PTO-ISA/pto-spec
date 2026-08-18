// PTO-TEST: {"id":"PTO-AVS-SCALAR-HL-ADDTPC-PAGE-001","source":"asl/scalar/bru/HL.ADDTPC.asl","requirements":["PTO-INST-SCALAR-HL-ADDTPC","PTO-HL-ADDTPC-PAGE-001"],"kind":"execution","summary":"HL.ADDTPC reconstructs a signed 4 KiB page displacement from its split imm32","pass_condition":"decoded split imm32 one writes TPC plus 0x1000 while scalar retirement advances TPC by six bytes","related_sources":["asl/scalar/model/bru/semantics.asl","asl/scalar/model/dispatch/bru.asl"]}
pure func HLADDTPCInstruction(destination: Reg5Selector,
                              immediate: bits(32)) => bits(48)
begin
    var instruction: bits(48) = Zeros{48} + 0x00000007000e;
    instruction[27:23] = Zeros{5} + destination;
    instruction[47:28] = immediate[19:0];
    instruction[15:4] = immediate[31:20];
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    let status = ExecuteScalarInstruction(
        HLADDTPCInstruction(3, Zeros{32} + 1),
        48);

    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x1100;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x106;
    assert InstructionContractImmediateWidth_HL_ADDTPC() == 32;
    assert InstructionContractImmediateIsSigned_HL_ADDTPC();
    assert InstructionContractPageShift_HL_ADDTPC() == 12;
    assert !InstructionContractWritesTPC_HL_ADDTPC();
    assert InstructionContractTarget_HL_ADDTPC(
        Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN} + 1) == Zeros{PTO_XLEN} + 0x1100;
    return 0;
end;
