// PTO-TEST: {"id":"PTO-AVS-ARCH-EXECUTE-ONE-STEP-FETCH-001","source":"asl/arch/dispatch/top-level.asl","requirements":[],"kind":"execution","summary":"Covers ASL-owned fetch length selection, little-endian assembly, and precise PC fault handling.","pass_condition":"TestExecuteOnePTOStepFetch completes without assertion failure","related_sources":["asl/arch/memory-model/address-space.asl"]}
func TestExecuteOnePTOStepFetch()
begin
    // The low-prefix rule is four-way: ordinary prefixes select 16/32 and
    // the 111 escape selects 48/64.
    assert PTOInstructionLengthFromHalfword(Zeros{16}) == 16;
    assert PTOInstructionLengthFromHalfword(Zeros{16} + 1) == 32;
    assert PTOInstructionLengthFromHalfword(Zeros{16} + 0x0e) == 48;
    assert PTOInstructionLengthFromHalfword(Zeros{16} + 0x0f) == 64;

    // 0x15 is the existing legal 32-bit scalar smoke instruction.  Storing
    // its bytes separately proves that fetch assembles them little-endian.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN});
    WriteMemoryByte(Zeros{PTO_XLEN}, Zeros{8} + 0x15);
    WriteMemoryByte(Zeros{PTO_XLEN} + 1, Zeros{8});
    WriteMemoryByte(Zeros{PTO_XLEN} + 2, Zeros{8} + 0xaa);
    WriteMemoryByte(Zeros{PTO_XLEN} + 3, Zeros{8} + 0xbb);
    let executed = ExecuteOnePTOStep();
    assert executed.status == PTOInstruction_Executed;
    assert executed.instruction == Zeros{64} + 0xbbaa0015;
    assert executed.length_bits == 32;
    assert executed.pc_before == Zeros{PTO_XLEN};
    assert executed.pc_after == Zeros{PTO_XLEN} + 4;
    assert executed.fault == Fault_None;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 1;

    // An odd TPC faults before fetch and does not select a length or execute
    // a decoded instruction.
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 1);
    let misaligned = ExecuteOnePTOStep();
    assert misaligned.status == PTOInstruction_Rejected;
    assert misaligned.length_bits == 0;
    assert misaligned.fault == Fault_InstructionPC;
    assert misaligned.fault_address == Zeros{PTO_XLEN} + 1;
    assert misaligned.pc_before == Zeros{PTO_XLEN} + 1;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN};
end;

func main() => integer
begin
    ResetProfileState();
    TestExecuteOnePTOStepFetch();
    return 0;
end;
