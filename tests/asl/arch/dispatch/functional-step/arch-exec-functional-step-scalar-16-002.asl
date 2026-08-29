// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-SCALAR-16-002","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-FETCH-001","PTO-REQ-FUNCTIONAL-STEP-001"],"kind":"execution","summary":"One fetched 16-bit C.MOVI executes through the functional step boundary.","pass_condition":"ExecuteOnePTOStep fetches two little-endian bytes, writes the decoded destination, and advances TPC by two bytes.","related_sources":["asl/scalar/alu/C.MOVI.asl"]}
func main() => integer
begin
    let entry = Zeros{PTO_XLEN} + 0x100;
    InitializeFunctionalModel(entry);
    WriteMemoryByte(entry, Zeros{8} + 0x16);
    WriteMemoryByte(entry + 1, Zeros{8} + 0x14);
    let pre_cycle = _SystemRegisters.cycle;

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Executed;
    assert result.pre_tpc == entry;
    assert result.post_tpc == entry + 2;
    assert result.raw_instruction == Zeros{64} + 0x1416;
    assert result.length_bits == 16;
    assert result.fault == Fault_None;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert ReadGPR(2) == Zeros{PTO_XLEN} + 0xfffffffffffffff0;
    assert ReadTPC() == entry + 2;
    return 0;
end;
