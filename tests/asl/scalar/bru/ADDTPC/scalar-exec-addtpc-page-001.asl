// PTO-TEST: {"id":"PTO-AVS-SCALAR-ADDTPC-PAGE-001","source":"asl/scalar/bru/ADDTPC.asl","requirements":["PTO-INST-SCALAR-ADDTPC","PTO-ADDTPC-PAGE-001"],"kind":"execution","summary":"ADDTPC uses a signed 4 KiB page displacement from the current TPC","pass_condition":"decoded imm20 one writes TPC plus 0x1000 while scalar retirement advances TPC by four bytes","related_sources":["asl/scalar/model/bru/semantics.asl","asl/scalar/model/dispatch/bru.asl"]}
pure func ADDTPCInstruction(destination: Reg5Selector,
                            immediate: bits(20)) => bits(48)
begin
    var instruction: bits(48) = Zeros{48} + 0x00000007;
    instruction[11:7] = Zeros{5} + destination;
    instruction[31:12] = immediate;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    let status = ExecuteScalarInstruction(
        ADDTPCInstruction(3, Zeros{20} + 1),
        32);

    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x1100;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    assert InstructionContractImmediateWidth_ADDTPC() == 20;
    assert InstructionContractImmediateIsSigned_ADDTPC();
    assert InstructionContractPageShift_ADDTPC() == 12;
    assert !InstructionContractWritesTPC_ADDTPC();
    assert InstructionContractTarget_ADDTPC(
        Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN} + 1) == Zeros{PTO_XLEN} + 0x1100;
    return 0;
end;
