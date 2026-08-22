// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-BLOCK-TESTBUNDLETILECOMMITLIFECYCLE-STATE-TRANSITION-001","source":"asl/block/model/commit/effects.asl","requirements":[],"kind":"state-transition","summary":"Covers Bundle Tile Commit Lifecycle.","pass_condition":"TestBundleTileCommitLifecycle completes without assertion failure","related_sources":[]}
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
    // Generic bundle fixtures use one-PE 256-byte source descriptors, so the
    // destination B.IOT uses SizeCode 2 and the matching PE3 mode.
    instruction[11:9] = '100';
    instruction[8:7] = destination;
    instruction[18:15] = Zeros{4} + 2;
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

func TestBundleTileCommitLifecycle()
begin
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 9);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    let start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    assert start == CommandExecution_Executed;
    assert BundleIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    let binding = ExecuteCommandInstruction(BundleTestTileBinding(
        '10', Zeros{6}, Zeros{6} + 1, TRUE), 32);
    assert binding == CommandExecution_Executed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;
    let stop = ExecuteCommandInstruction(Zeros{64} + 1, 32);
    assert stop == CommandExecution_Executed;
    assert !BundleIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x10c;
    // DstTile selects hand 2, not physical tile 2. The first free tile in
    // hand 2 is tile 32; the pre-existing physical tile 2 is preserved.
    assert _Tiles[[32]].allocated;
    assert ReadTileElement(32, 0, 0) == Zeros{PTO_XLEN} + 16;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 3;

    // A following BSTART is also a commit boundary and installs only the next
    // descriptor after the previous tile effect succeeds.
    ResetProfileState();
    BundleTestConfigureTile(0, TileDataType_U64);
    BundleTestConfigureTile(1, TileDataType_U64);
    BundleTestConfigureTile(2, TileDataType_U64);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 99);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);
    let first_start = ExecuteCommandInstruction(
        BundleTestTEPLStart(Zeros{10}, Zeros{5} + 24), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    let first_binding = ExecuteCommandInstruction(BundleTestTileBinding(
        '10', Zeros{6}, Zeros{6} + 1, TRUE), 32);
    var next_start: bits(64) = Zeros{64} + 0x00000011;
    next_start[31:7] = Zeros{25} + 4;
    let next_status = ExecuteCommandInstruction(next_start, 32);
    assert first_start == CommandExecution_Executed;
    assert first_binding == CommandExecution_Executed;
    assert next_status == CommandExecution_Executed;
    assert _Tiles[[32]].allocated;
    assert ReadTileElement(32, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert _BundleOperation.operation_class == BundleOperation_Control;
    assert !_BundleOperation.selector_valid;
    assert BundleIsActive();
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x20c;
    assert _SystemRegisters.cycle == Zeros{PTO_XLEN} + 3;
end;
func main() => integer
begin
    ResetProfileState();
    TestBundleTileCommitLifecycle();
    return 0;
end;
