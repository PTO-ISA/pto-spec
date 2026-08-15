// PTO-TEST: {"id":"PTO-AVS-BLOCK-C-B-DIMI-DUP-001","source":"asl/block/attributes/C.B.DIMI.asl","requirements":["PTO-INST-BLOCK-C-B-DIMI"],"kind":"fault","summary":"C.B.DIMI and B.DIM share one write-once presence bit for each LB","pass_condition":"a duplicate in either cross-form order raises Fault_BundleControl before replacing the first LB value","related_sources":["asl/block/attributes/B.DIM.asl","asl/block/model/schema/dimensions.asl"]}
func main() => integer
begin
    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x202,
        Zeros{PTO_XLEN} + 0x202,
        Zeros{PTO_XLEN} + 0x202,
        FALSE);

    var compressed_lb1: bits(64) = Zeros{64} + 0x003c;
    compressed_lb1[15:14] = '01';
    compressed_lb1[13:6] = Zeros{8} + 7;
    let compressed_first = ExecuteCommandInstruction(compressed_lb1, 16);
    assert compressed_first == CommandExecution_Executed;

    var full_lb1: bits(64) = Zeros{64} + 0x1043;
    full_lb1[31:20] = Zeros{12} + 9;
    ClearFault();
    let full_second = ExecuteCommandInstruction(full_lb1, 32);
    assert full_second == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleDimensions[[1]] == Zeros{PTO_XLEN} + 7;

    ResetProfileState();
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Fallthrough,
        Zeros{PTO_XLEN} + 0x302,
        Zeros{PTO_XLEN} + 0x302,
        Zeros{PTO_XLEN} + 0x302,
        FALSE);
    var full_lb2: bits(64) = Zeros{64} + 0x2043;
    full_lb2[31:20] = Zeros{12} + 11;
    let full_first = ExecuteCommandInstruction(full_lb2, 32);
    assert full_first == CommandExecution_Executed;

    var compressed_lb2: bits(64) = Zeros{64} + 0x003c;
    compressed_lb2[15:14] = '10';
    compressed_lb2[13:6] = Zeros{8} + 13;
    ClearFault();
    let compressed_second = ExecuteCommandInstruction(compressed_lb2, 16);
    assert compressed_second == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert _BundleDimensions[[2]] == Zeros{PTO_XLEN} + 11;
    return 0;
end;
