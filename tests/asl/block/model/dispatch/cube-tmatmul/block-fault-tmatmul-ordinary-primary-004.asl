// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ORDINARY-PRIMARY-004","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"fault","summary":"Local TMATMUL rejects ordinary row-major primary operands","pass_condition":"row-major A and B raise Tile legality before destination allocation source mutation payload computation or numeric status","related_sources":["asl/tile/model/legality/matrix-operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTileForMask(1, 128, 8, 8, 1, 1,
        TileDataType_FP16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    ConfigureTileForMask(2, 128, 8, 8, 1, 1,
        TileDataType_FP16, TileLayout_RowMajor,
        TileLocation_Matrix, '1111');
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    let left_before = _Tiles[[1]];
    let right_before = _Tiles[[2]];
    let status_before = NumericStatusFlags();

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();

    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert CoreTileCapacityInUse() == 1024;
    assert _Tiles[[1]].payload[[0]] == left_before.payload[[0]];
    assert _Tiles[[2]].payload[[0]] == right_before.payload[[0]];
    assert _Tiles[[1]].allocated && _Tiles[[2]].allocated;
    assert NumericStatusFlags() == status_before;
    return 0;
end;
