// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SHARED-MSHARD-021","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-SHARED-M-SHARD-001"],"kind":"execution","summary":"Cooperative Shared-A TMATMUL selects the current PE's LB0-row shard.","pass_condition":"Four independent PE executions consume distinct Shared-A rows and publish the corresponding one-row Local results.","related_sources":["asl/block/model/dispatch/shared-cube-matrix.asl"]}
func ExecuteSharedMShardForPE(pe: MemoryAgentId, expected: integer)
begin
    ResetProfileState();
    SelectMemoryEventAgent(pe);

    ConfigureTileForMask(10, 128, 64, 1, 4, 1,
        TileDataType_U16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(11, 128, 128, 1, 1, 1,
        TileDataType_U8, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    for row = 0 to 3 do
        WriteTileElement(10, row, 0, Zeros{PTO_XLEN} + row + 2);
    end;
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 10);
    InstallSharedTile((Zeros{6} + 40) as SharedTileID,
        _Tiles[[10]], '1111');
    InstallSharedTile((Zeros{6} + 41) as SharedTileID,
        _Tiles[[11]], '1111');

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 26;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 27, Zeros{5}, Zeros{2}, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    BindBundleSharedIO((Zeros{6} + 40) as SharedTileID, 0, '1111');
    BindBundleSharedIO((Zeros{6} + 41) as SharedTileID, 0, '1111');
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + expected;
end;

func main() => integer
begin
    ExecuteSharedMShardForPE(0, 20);
    ExecuteSharedMShardForPE(1, 30);
    ExecuteSharedMShardForPE(2, 40);
    ExecuteSharedMShardForPE(3, 50);
    return 0;
end;
