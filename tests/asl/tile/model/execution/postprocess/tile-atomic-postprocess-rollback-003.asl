// PTO-TEST: {"id":"PTO-AVS-TILE-POSTPROCESS-ROLLBACK-003","source":"asl/tile/model/execution/postprocess.asl","requirements":["PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"atomicity","summary":"matrix postprocess rejects a late GroupMax capacity failure before any publication","pass_condition":"D RowMaxOut GroupMaxOut allocation flags capacity and source payload remain unchanged","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/cube-tmatmul.asl"]}
pure func MatrixPostProcessRollbackStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(1, 1024, 1, 512, 1, 512, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    for column = 0 to 511 looplimit 512 do
        WriteTileElement(1, 0, column, Zeros{PTO_XLEN} + 0x3c00);
    end;

    let started = ExecuteCommandInstruction(
        MatrixPostProcessRollbackStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 512);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 5, '1111', TRUE, TRUE, 0, 1, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', FALSE, FALSE, 0, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 2, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let capacity_before = CoreTileCapacityInUse();
    let source0_before = ReadTileElement(0, 0, 0);
    let source1_before = ReadTileElement(1, 0, 511);
    RecordNumericStatusFlags(Zeros{5} + 1);
    let flags_before = NumericStatusFlags();

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert CoreTileCapacityInUse() == capacity_before;
    assert ReadTileElement(0, 0, 0) == source0_before;
    assert ReadTileElement(1, 0, 511) == source1_before;
    assert NumericStatusFlags() == flags_before;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    assert !_BundleTileBindings[[2]].destination_allocated_by_bundle;
    return 0;
end;
