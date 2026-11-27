// PTO-TEST: {"id":"PTO-AVS-SCALAR-CORE-PGAS-TRANSLATION-CONTEXT-001","source":"asl/scalar/model/sys/semantics.asl","requirements":["PTO-CORE-PGAS-RANGE-001","PTO-CORE-PGAS-SSR-001"],"kind":"state-transition","summary":"Encoded PGAS discovery remains Core-owned across translation-context register changes","pass_condition":"Two encoded HL.SSRSET updates to the ACR1 TTBR0 and TCR are observable while SSRGET and HL.SSRGET in ACR1 continue to return the configured Core PGAS endpoints","related_sources":["asl/arch/data-types/system-registers.asl","asl/arch/system-registers/addressing.asl","asl/scalar/sys/HL.SSRGET.asl","asl/scalar/sys/HL.SSRSET.asl","asl/scalar/sys/SSRGET.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured = ConfigureCorePGAS(
        1, 0x0000001200000000, 0x0000001200010000);
    assert configured;
    SelectExecutionContext(1, 2);
    SetCurrentACR(0);
    BeginBundle(BundleKind_System, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x100,
        Zeros{PTO_XLEN}, FALSE);
    EnterBundleBody();

    WriteGPR(2, Zeros{PTO_XLEN} + 0x0000000080001000);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x0000000000000041);
    var set_ttbr: bits(48) = Zeros{48} + 0x0000103b000e;
    set_ttbr[47:36] = Zeros{12} + 0xf10;
    set_ttbr[15:4] = Zeros{12} + 1;
    set_ttbr[35:31] = Zeros{5} + 2;
    var set_tcr: bits(48) = Zeros{48} + 0x0000103b000e;
    set_tcr[47:36] = Zeros{12} + 0xf12;
    set_tcr[15:4] = Zeros{12} + 1;
    set_tcr[35:31] = Zeros{5} + 5;
    let first_ttbr = ExecutePTOInstruction(ZeroExtend{64}(set_ttbr), 48);
    assert first_ttbr == PTOInstruction_Executed;
    let first_tcr = ExecutePTOInstruction(ZeroExtend{64}(set_tcr), 48);
    assert first_tcr == PTOInstruction_Executed;
    let first_ttbr_value = ReadSystemRegisterAddress(Zeros{24} + 0x1f10);
    let first_tcr_value = ReadSystemRegisterAddress(Zeros{24} + 0x1f12);
    assert first_ttbr_value ==
        Zeros{PTO_XLEN} + 0x0000000080001000;
    assert first_tcr_value ==
        Zeros{PTO_XLEN} + 0x0000000000000041;

    SetCurrentACR(1);
    let first_base = ExecutePTOInstruction(Zeros{64} + 0x028001bb, 32);
    assert first_base == PTOInstruction_Executed;
    let first_limit = ExecutePTOInstruction(Zeros{64} + 0x0290023b000e, 48);
    assert first_limit == PTOInstruction_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x0000001200000000;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x0000001200010000;

    SetCurrentACR(0);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x0000000090002000);
    WriteGPR(5, Zeros{PTO_XLEN} + 0x0000000000000082);
    let second_ttbr = ExecutePTOInstruction(ZeroExtend{64}(set_ttbr), 48);
    assert second_ttbr == PTOInstruction_Executed;
    let second_tcr = ExecutePTOInstruction(ZeroExtend{64}(set_tcr), 48);
    assert second_tcr == PTOInstruction_Executed;
    let second_ttbr_value = ReadSystemRegisterAddress(Zeros{24} + 0x1f10);
    let second_tcr_value = ReadSystemRegisterAddress(Zeros{24} + 0x1f12);
    assert second_ttbr_value ==
        Zeros{PTO_XLEN} + 0x0000000090002000;
    assert second_tcr_value ==
        Zeros{PTO_XLEN} + 0x0000000000000082;

    SetCurrentACR(1);
    let second_base = ExecutePTOInstruction(Zeros{64} + 0x0280023b000e, 48);
    assert second_base == PTOInstruction_Executed;
    let second_limit = ExecutePTOInstruction(Zeros{64} + 0x029001bb, 32);
    assert second_limit == PTOInstruction_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x0000001200000000;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x0000001200010000;
    assert _LastFault == Fault_None;
    StopBundle();
    return 0;
end;
