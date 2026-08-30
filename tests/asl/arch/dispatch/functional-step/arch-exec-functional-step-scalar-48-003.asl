// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-SCALAR-48-003","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001","PTO-INST-SCALAR-HL-XORI"],"kind":"execution","summary":"One fetched 48-bit HL.XORI executes through the functional step boundary.","pass_condition":"ExecuteOnePTOStep fetches six little-endian bytes, executes the signed immediate XOR, and advances TPC by six bytes.","related_sources":["asl/scalar/alu/HL.XORI.asl"]}
func main() => integer
begin
    let entry = Zeros{PTO_XLEN} + 0x100;
    InitializeFunctionalModel(entry);
    let initialized = InitializeFunctionalModelGPR(
        1,
        Zeros{PTO_XLEN});
    assert initialized;
    WriteMemoryByte(entry, Zeros{8} + 0x0e);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x80);
    WriteMemoryByte(entry + 2, Zeros{8} + 0x95);
    WriteMemoryByte(entry + 3, Zeros{8} + 0xc0);
    WriteMemoryByte(entry + 4, Zeros{8});
    WriteMemoryByte(entry + 5, Zeros{8});
    let pre_cycle = _SystemRegisters.cycle;

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Executed;
    assert result.instruction_status == PTOFunctionalInstruction_Executed;
    assert result.pre_tpc == entry;
    assert result.post_tpc == entry + 6;
    assert result.raw_instruction == Zeros{64} + 0xc095800e;
    assert result.length_bits == 48;
    assert result.fault == Fault_None;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert ReadGPR(1) == Zeros{PTO_XLEN} + 0xffffffffff800000;
    assert ReadTPC() == entry + 6;
    return 0;
end;
