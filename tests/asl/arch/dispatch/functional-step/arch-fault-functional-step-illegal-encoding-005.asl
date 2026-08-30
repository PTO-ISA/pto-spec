// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-ILLEGAL-ENCODING-005","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001","PTO-REQ-INSTRUCTION-DISPATCH-001"],"kind":"fault","summary":"A fully fetched 64-bit value with no accepted form raises IllegalInstruction.","pass_condition":"ExecuteOnePTOStep reports the decoded IllegalInstruction fault at the original TPC after fetching all eight bytes and preserves a sentinel GPR.","related_sources":["asl/arch/dispatch/top-level.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    let entry = Zeros{PTO_XLEN} + 0x100;
    InitializeFunctionalModel(entry);
    let initialized = InitializeFunctionalModelGPR(
        2,
        Zeros{PTO_XLEN} + 0x55);
    assert initialized;
    WriteMemoryByte(entry, Zeros{8} + 0x0f);
    for offset = 1 to 7 do
        WriteMemoryByte(entry + NaturalToWord(offset), Zeros{8});
    end;
    let pre_cycle = _SystemRegisters.cycle;

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Trap;
    assert result.instruction_status == PTOFunctionalInstruction_Rejected;
    assert result.pre_tpc == entry;
    assert result.raw_instruction == Zeros{64} + 0x0f;
    assert result.length_bits == 64;
    assert result.fault == Fault_IllegalInstruction;
    assert result.fault_address == entry;
    assert _LastFault == Fault_IllegalInstruction;
    assert _FaultAddress == entry;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert ReadPEGPR(0, 2) == Zeros{PTO_XLEN} + 0x55;
    return 0;
end;
