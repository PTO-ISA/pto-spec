// PTO-TEST: {"id":"PTO-AVS-BLOCK-BSTART-SFU-ALIAS-ROLLBACK-001","source":"asl/block/execution/BSTART.SFU.asl","requirements":["PTO-INST-BLOCK-BSTART-SFU"],"kind":"fault","summary":"The SFU alias inherits TEPL predecessor-retirement rollback.","pass_condition":"A failing predecessor commit preserves the retiring BARG and descriptor and installs no TEXP alias descriptor.","related_sources":["asl/block/execution/BSTART.TEPL.asl","asl/block/model/dispatch/start.asl"]}
func main() => integer
begin
    ResetProfileState();
    SetCurrentACR(0);
    WriteTPC(Zeros{PTO_XLEN} + 0x400);
    BeginBundleAt(ReadTPC(), BundleKind_Standard, BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x600, Zeros{PTO_XLEN} + 0x404,
        Zeros{PTO_XLEN}, TRUE);
    _BundleOperation.valid = TRUE;
    _BundleOperation.operation_class = BundleOperation_FixedPoint;

    let status = ExecuteCommandInstruction(Zeros{64} + 0x09219181, 32);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert _BundleActive;
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x600;
    assert _BARG.transfer_type == BundleTransfer_Direct;
    assert _BundleOperation.valid;
    assert _BundleOperation.operation_class == BundleOperation_FixedPoint;
    assert !_BundleOperation.selector_valid;
    return 0;
end;
