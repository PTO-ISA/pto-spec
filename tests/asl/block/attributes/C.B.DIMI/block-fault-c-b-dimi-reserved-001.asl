// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-B-DIMI-RSVD-001","source":"asl/block/attributes/C.B.DIMI.asl","requirements":["PTO-INST-BLOCK-C-B-DIMI"],"kind":"fault","summary":"C.B.DIMI reserves LoopNest code three","pass_condition":"the reserved form raises Fault_IllegalInstruction before changing any LB value, presence bit, or TPC","related_sources":["asl/block/model/dispatch/top-level.asl","asl/block/model/dispatch/decode.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x600);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x602,
        Zeros{PTO_XLEN} + 0x602,
        Zeros{PTO_XLEN} + 0x602,
        FALSE);
    var instruction: bits(64) = Zeros{64} + 0x003c;
    instruction[15:14] = '11';
    instruction[13:6] = Ones{8};

    let status = ExecuteCommandInstruction(instruction, 16);
    assert status == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert !_BundleDimensionPresent[[0]];
    assert !_BundleDimensionPresent[[1]];
    assert !_BundleDimensionPresent[[2]];
    assert _TrapContexts[[0]].tpc == Zeros{PTO_XLEN} + 0x602;
    return 0;
end;
