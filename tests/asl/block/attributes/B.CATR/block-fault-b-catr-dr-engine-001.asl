// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-CATR-DR-ENGINE-001","source":"asl/block/attributes/B.CATR.asl","requirements":["PTO-INST-BLOCK-B-CATR"],"kind":"fault","summary":"Dimension reduction is restricted to VEC, SFU, and TLSU engines.","pass_condition":"CUBE and non-tile blocks reject DR before effects while a VEC-class block accepts it.","related_sources":["asl/block/model/commit/validation.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundle(BundleKind_TileMatrix, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x104, Zeros{PTO_XLEN} + 0x104,
        Zeros{PTO_XLEN} + 0x104, TRUE);
    _BundleControlAttributes.present = TRUE;
    _BundleControlAttributes.dimension_reduction = TRUE;
    let cube = CompleteBundleAt(Zeros{PTO_XLEN} + 0x104);
    assert !cube;
    assert _LastFault == Fault_BundleControl;
    assert _BundleActive;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    BeginBundle(BundleKind_TileElement, BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x204, Zeros{PTO_XLEN} + 0x204,
        Zeros{PTO_XLEN} + 0x204, TRUE);
    _BundleControlAttributes.present = TRUE;
    _BundleControlAttributes.dimension_reduction = TRUE;
    let vec = CompleteBundleAt(Zeros{PTO_XLEN} + 0x204);
    assert vec;
    assert _LastFault == Fault_None;
    return 0;
end;
