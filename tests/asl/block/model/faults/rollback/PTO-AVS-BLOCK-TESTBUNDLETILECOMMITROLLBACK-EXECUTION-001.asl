// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLETILECOMMITROLLBACK-EXECUTION-001","source":"asl/block/model/faults/rollback.asl","requirements":[],"kind":"execution","summary":"migrated independent behavior point for TestBundleTileCommitRollback","pass_condition":"TestBundleTileCommitRollback completes without assertion failure","related_sources":[]}
pure func BundleTestTEPLStart(selector: bits(10), data_type: bits(5))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

pure func BundleTestTileBinding(destination: bits(2), source0: bits(6),
                               source1: bits(6), last: boolean) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    // Generic bundle fixtures use 256-byte source descriptors, so the
    // destination B.IOT must select the matching per-PE capacity.
    instruction[11:9] = '010';
    instruction[8:7] = destination;
    instruction[18:15] = Zeros{4} + 3;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = if last then '1' else '0';
    return instruction;
end;

func BundleTestConfigureTile(index: TileIndex, data_type: TileDataType)
begin
    ConfigureTile(index, 256, 1, 1, 1, 1, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestBundleTileCommitRollback()
begin
    // Missing B.IOT is a bundle-control fault with no destination update.
    ResetProfileState();
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    let missing_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let missing_stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert missing_start == CommandExecution_Executed;
    assert missing_stop == CommandExecution_Rejected;
    assert _LastFault == Fault_BundleControl;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;

    // A faulting next start is validated before it can commit the live bundle.
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x300);
    let live_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    let live_binding = ExecuteCommandInstruction(BundleTestTileBinding(
        '10', Zeros{6}, Zeros{6} + 1, TRUE), 32);
    let invalid_next = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10} + 14, Zeros{5} + 24), 32);
    assert live_start == CommandExecution_Executed;
    assert live_binding == CommandExecution_Executed;
    assert invalid_next == CommandExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _TrapContexts[[0]].bundle_active;
    assert _TrapContexts[[0]].bundle_operation.selector == Zeros{10};
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleTileCommitRollback();
    return 0;
end;
