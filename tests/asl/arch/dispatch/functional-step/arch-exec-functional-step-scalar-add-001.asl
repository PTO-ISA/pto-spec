// PTO-TEST: {"id":"PTO-AVS-ARCH-FUNCTIONAL-STEP-SCALAR-ADD-001","source":"asl/arch/dispatch/functional-step.asl","requirements":["PTO-REQ-FUNCTIONAL-STEP-001"],"kind":"execution","summary":"One fetched scalar ADD updates the selected PE GPR and advances TPC by four bytes.","pass_condition":"ExecuteOnePTOStep executes the little-endian ADD, writes GPR3=30, and changes TPC from 0x100 to 0x104.","related_sources":["asl/arch/dispatch/top-level.asl","asl/scalar/alu/ADD.asl"]}
func main() => integer
begin
    InitializeFunctionalModel(Zeros{PTO_XLEN} + 0x100);
    let initialized_left = InitializeFunctionalModelGPR(
        1, Zeros{PTO_XLEN} + 10);
    assert initialized_left;
    let initialized_right = InitializeFunctionalModelGPR(
        2, Zeros{PTO_XLEN} + 20);
    assert initialized_right;
    // ADD R1, R2.sw, ->R3 with SrcRType=00 and shamt=0: 0x00208185.
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x100, Zeros{8} + 0x85);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x101, Zeros{8} + 0x81);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x102, Zeros{8} + 0x20);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0x103, Zeros{8});
    let pre_cycle = _SystemRegisters.cycle;

    let result = ExecuteOnePTOStep();

    assert result.status == PTOFunctionalStep_Executed;
    assert result.pre_tpc == Zeros{PTO_XLEN} + 0x100;
    assert result.post_tpc == Zeros{PTO_XLEN} + 0x104;
    assert result.raw_instruction == Zeros{64} + 0x00208185;
    assert result.length_bits == 32;
    assert result.fault == Fault_None;
    assert result.origin_pe == 0;
    assert result.sequence == _FunctionalProfileSequence;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == pre_cycle + 1;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 30;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    return 0;
end;
