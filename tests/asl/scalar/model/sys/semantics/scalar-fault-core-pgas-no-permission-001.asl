// PTO-TEST: {"id":"PTO-AVS-SCALAR-CORE-PGAS-NO-PERMISSION-001","source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-CORE-PGAS-RANGE-001","PTO-CORE-PGAS-SSR-001"],"kind":"fault","summary":"PGAS discovery does not grant memory access to the reported virtual range","pass_condition":"encoded SSRGET discovers an address that still faults under ACR2 bounded-memory permission while the same encoded LW succeeds under ACR1","related_sources":["asl/arch/system-registers/addressing.asl","asl/scalar/agu/LW.asl","asl/scalar/model/agu/memory.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCorePGAS(0, 2048, 4096);
    assert configured;
    SelectExecutionContext(0, 1);
    SetCurrentACR(2);

    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();
    let discovered = ExecutePTOInstruction(Zeros{64} + 0x028001bb, 32);
    assert discovered == PTOInstruction_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 2048;
    let discovered_limit = ExecutePTOInstruction(
        Zeros{64} + 0x0290023b000e, 48);
    assert discovered_limit == PTOInstruction_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 4096;
    StopBundle();

    let target = Zeros{PTO_XLEN} + 3072;
    WriteMemoryByte(target, Zeros{8} + 0x78);
    WriteMemoryByte(target + 1, Zeros{8} + 0x56);
    WriteMemoryByte(target + 2, Zeros{8} + 0x34);
    WriteMemoryByte(target + 3, Zeros{8} + 0x12);
    WriteGPR(2, target);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x5555);
    WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    StartMemoryEventCapture(1);

    var lw: bits(48) = Zeros{48} + 0x00002009;
    lw[11:7] = Zeros{5} + 5;
    lw[19:15] = Zeros{5} + 2;
    lw[24:20] = Zeros{5};
    let denied = ExecuteScalarInstruction(lw, 32);
    assert denied == ScalarExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == target;
    assert CurrentACR() == 1;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x5555;
    assert _MemoryEventCount == 0;

    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert CurrentACR() == 2;
    SetCurrentACR(1);
    ClearFault();
    let allowed = ExecuteScalarInstruction(lw, 32);
    assert allowed == ScalarExecution_Executed;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 0x12345678;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].address == target;
    assert _MemoryEvents[[0]].size_bytes == 4;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert !_MemoryEvents[[0]].write_performed;
    assert _LastFault == Fault_None;
    StopMemoryEventCapture();
    return 0;
end;
