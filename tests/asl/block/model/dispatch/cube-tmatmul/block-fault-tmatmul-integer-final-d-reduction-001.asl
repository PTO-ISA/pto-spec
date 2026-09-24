// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-INTEGER-FINAL-D-REDUCTION-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-FPATR-MATRIX-POSTPROCESS-001","PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"fault","summary":"No-quant S32 and U32 reductions fail complete-bundle preflight","pass_condition":"both integer accumulator classes raise tile legality without snapshots changing sources numeric status or allocating/publishing D or RowMaxOut","related_sources":["asl/tile/model/legality/matrix-postprocess.asl","asl/block/model/dispatch/cube-destination.asl"]}

func RunIntegerFinalDReductionCase(input_type: TileDataType,
                                  input_code: bits(5))
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        input_type, TileLayout_CUBE_M16, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        input_type, TileLayout_CUBE_N8, '1111');
    assert a_ready && b_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    let a_before = ReadTileElement(1, 0, 0);
    let b_before = ReadTileElement(2, 0, 0);
    let capacity_before = CoreTileCapacityInUse();
    let status_before = NumericStatusFlags();

    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = input_code;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, TRUE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert !_BundleTileBindings[[1]].destination_allocated_by_bundle;
    assert !_Tiles[[0]].allocated;
    assert !_Tiles[[16]].allocated;
    assert CoreTileCapacityInUse() == capacity_before;
    assert NumericStatusFlags() == status_before;
    assert ReadTileElement(1, 0, 0) == a_before;
    assert ReadTileElement(2, 0, 0) == b_before;
end;

func main() => integer
begin
    RunIntegerFinalDReductionCase(
        TileDataType_S8, Zeros{5} + 19);
    RunIntegerFinalDReductionCase(
        TileDataType_U8, Zeros{5} + 27);
    return 0;
end;
