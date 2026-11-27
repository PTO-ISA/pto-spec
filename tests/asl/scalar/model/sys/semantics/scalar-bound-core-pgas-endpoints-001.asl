// PTO-TEST: {"id":"PTO-AVS-SCALAR-CORE-PGAS-ENDPOINTS-001","source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-CORE-PGAS-RANGE-001","PTO-CORE-PGAS-SSR-001"],"kind":"boundary","summary":"Encoded PGAS reads preserve the unsigned midpoint and maximum XLEN endpoint boundaries","pass_condition":"SSRGET and HL.SSRGET return the exact configured pairs on different Cores, PEs, and high-numbered ACRs without truncation or memory effects","related_sources":["asl/arch/system-registers/addressing.asl","asl/scalar/sys/SSRGET.asl","asl/scalar/sys/HL.SSRGET.asl"]}
func main() => integer
begin
    ResetProfileState();
    let midpoint = ConfigureCorePGAS(
        0, 0x7fffffffffffffff, 0x8000000000000000);
    assert midpoint;
    let maximum = ConfigureCorePGAS(
        1, 0xfffffffffffffffe, 0xffffffffffffffff);
    assert maximum;

    SelectExecutionContext(0, 3);
    SetCurrentACR(15);
    StartMemoryEventCapture(3);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    let core0_base = ExecutePTOInstruction(Zeros{64} + 0x028001bb, 32);
    assert core0_base == PTOInstruction_Executed;
    let core0_limit = ExecutePTOInstruction(Zeros{64} + 0x0290023b000e, 48);
    assert core0_limit == PTOInstruction_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x7fffffffffffffff;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x8000000000000000;
    assert _MemoryEventCount == 0;
    assert _LastFault == Fault_None;
    StopMemoryEventCapture();
    StopBundle();

    SelectExecutionContext(1, 0);
    SetCurrentACR(14);
    StartMemoryEventCapture(0);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x200,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    let core1_base = ExecutePTOInstruction(Zeros{64} + 0x0280023b000e, 48);
    assert core1_base == PTOInstruction_Executed;
    let core1_limit = ExecutePTOInstruction(Zeros{64} + 0x029001bb, 32);
    assert core1_limit == PTOInstruction_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0xfffffffffffffffe;
    assert ReadGPR(3) == Ones{PTO_XLEN};
    assert _MemoryEventCount == 0;
    assert _LastFault == Fault_None;
    StopMemoryEventCapture();
    StopBundle();
    return 0;
end;
