// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-B-DIMI-PLACE-001","source":"asl/block/attributes/C.B.DIMI.asl","requirements":["PTO-INST-BLOCK-C-B-DIMI"],"kind":"fault","summary":"C.B.DIMI is legal only in an active block header","pass_condition":"standalone and block-body executions raise Fault_BundleControl before setting an LB presence bit or value","related_sources":["asl/block/model/dispatch/commands.asl"]}
func main() => integer
begin
    let instruction: bits(64) = Zeros{64} + 0x007c;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    let standalone = ExecuteCommandInstruction(instruction, 16);
    assert standalone == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleDimensionPresent[[0]];

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x500);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x502,
        Zeros{PTO_XLEN} + 0x502,
        Zeros{PTO_XLEN} + 0x502,
        FALSE);
    EnterBundleBody();
    ClearFault();
    let body = ExecuteCommandInstruction(instruction, 16);
    assert body == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert !_BundleDimensionPresent[[0]];
    return 0;
end;
