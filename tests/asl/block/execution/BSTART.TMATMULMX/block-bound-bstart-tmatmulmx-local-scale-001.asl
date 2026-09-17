// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMULMX-LOCAL-SCALE-001","source":"asl/block/execution/BSTART.TMATMULMX.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001","PTO-INST-BLOCK-BSTART-TMATMULMX"],"kind":"boundary","summary":"Decoded TMATMULMX bounds Local CUBE_M32 B scales at N=32 while preserving Shared ordinary scales beyond that bound.","pass_condition":"A decoded Local E4M3 operation with N=32 publishes an FP32 destination; the same Local B-scale descriptor rejects N=33 with Fault_TileLegality before destination allocation or publication; a representable Shared RowMajor B and scale remain legal at N=64 and publish a destination.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/block/model/dispatch/shared-cube-matrix.asl","asl/tile/model/legality/matrix-shape.asl"]}

func StartTMATMULMX()
begin
    var start: bits(64) = Zeros{64} + 0x00431181;
    start[31:27] = Zeros{5} + 7;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
end;

func ConfigureLocalBoundary(n: integer {32,33})
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_E4M3, TileLayout_CUBE_M16, '1111');
    let a_scale_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_E8M0, TileLayout_CUBE_M32, '1111');
    let b_ready = ConfigureCubeTileForMask(3, 1024, 1, n,
        TileDataType_E4M3, TileLayout_CUBE_N8, '1111');
    let b_scale_ready = ConfigureCubeTileForMask(4, 128, 32, 1,
        TileDataType_E8M0, TileLayout_CUBE_M32, '1111');
    assert a_ready && a_scale_ready && b_ready && b_scale_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    for column = 0 to 32 looplimit 33 do
        if column < n then
            WriteTileElement(3, 0, column, Zeros{PTO_XLEN} + 3);
        end;
    end;
    for row = 0 to 31 looplimit 32 do
        WriteTileElement(4, row, 0, Zeros{PTO_XLEN} + 1);
    end;
    MarkTileValidRegionDefined(2);
    MarkTileValidRegionDefined(4);
    StartTMATMULMX();
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(1, Zeros{PTO_XLEN} + n);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 6, '1111', TRUE, TRUE, 3, 4, TRUE);
    assert TileMatrixInfoOptionalScalesLegal(
        _Tiles[[1]], _Tiles[[2]], TRUE,
        _Tiles[[3]], _Tiles[[4]], TRUE) == (n == 32);
end;

func TestLocalN32()
begin
    ConfigureLocalBoundary(32);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 6;
end;

func TestLocalN33RejectsBeforeEffects()
begin
    ConfigureLocalBoundary(33);
    let source_value = ReadTileElement(1, 0, 0);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    assert ReadTileElement(1, 0, 0) == source_value;
end;

pure func SharedTMATMULSource(shared_tile_id: bits(6)) => bits(64)
begin
    var instruction = Zeros{64} + 0x00001013;
    instruction[25:20] = shared_tile_id;
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '111';
    return instruction;
end;

func TestSharedN64RemainsLegal()
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_E4M3, TileLayout_CUBE_M16, '1111');
    let a_scale_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_E8M0, TileLayout_CUBE_M32, '1111');
    var b_ready = TRUE;
    ConfigureTile(3, 4096, 64, 1, 64, 1,
        TileDataType_E4M3, TileLayout_RowMajor);
    var b_scale_ready = TRUE;
    ConfigureTile(4, 4096, 64, 1, 64, 1,
        TileDataType_E8M0, TileLayout_RowMajor);
    assert a_ready && a_scale_ready && b_ready && b_scale_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 1);
    for row = 0 to 63 looplimit 64 do
        WriteTileElement(3, row, 0, Zeros{PTO_XLEN} + 3);
        WriteTileElement(4, row, 0, Zeros{PTO_XLEN} + 1);
    end;
    MarkTileValidRegionDefined(2);
    MarkTileValidRegionDefined(4);
    InstallSharedTile((Zeros{6} + 9) as SharedTileID,
        _Tiles[[3]], '1111');
    InstallSharedTile((Zeros{6} + 10) as SharedTileID,
        _Tiles[[4]], '1111');
    StartTMATMULMX();
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 64);
    let shared_primary = ExecuteCommandInstruction(
        SharedTMATMULSource(Zeros{6} + 9), 32);
    let shared_scale = ExecuteCommandInstruction(
        SharedTMATMULSource(Zeros{6} + 10), 32);
    assert shared_primary == CommandExecution_Executed &&
           shared_scale == CommandExecution_Executed;
    AddBundleTileBinding(TRUE, 0, 6, '1111', TRUE, TRUE, 1, 2, TRUE);
    let decoded = DecodeTileOperation(
        TileDecode_CUBE, BundleOperationDecodeCode(_BundleOperation));
    assert decoded != PTO_TILE_OPERATION_COUNT;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} + 6;
end;

func main() => integer
begin
    TestLocalN32();
    TestLocalN33RejectsBeforeEffects();
    TestSharedN64RemainsLegal();
    return 0;
end;
