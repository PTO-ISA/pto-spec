// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ACC-TYPES-022","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-DATR-MATRIX-ACC-CONTROL-001","PTO-CUBE-ACCUMULATOR-OUTPUT-001","PTO-CUBE-INTERNAL-ACCUMULATOR-001"],"kind":"execution","summary":"ACC forms use explicit FP32 S32 and U32 accumulator classes for every CCTRL value.","pass_condition":"all four FP32 CCTRL values and representative integer classes publish C plus A times B into distinct D while preserving explicit C.","related_sources":["asl/tile/model/execution/cube.asl","asl/tile/model/execution/internal-accumulator.asl","asl/tile/model/legality/matrix-shape.asl"]}
func RunAccumulatorTypeCase(input_type: TileDataType,
                            input_encoding: bits(5),
                            accumulator_type: TileDataType,
                            cctrl: bits(2))
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(4, 128, 1, 1,
        input_type, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(5, 128, 1, 1,
        input_type, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let c_ready = ConfigureCubeTileForMask(6, 128, 1, 1,
        accumulator_type, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready && c_ready;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} +
        (if input_type == TileDataType_FP16 then 0x4000 else 2));
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} +
        (if input_type == TileDataType_FP16 then 0x4200 else 3));
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} +
        (if accumulator_type == TileDataType_FP32 then 0x40a00000 else 5));
    let c_before = ReadTileElement(6, 0, 0);

    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = input_encoding;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(
        input_encoding, Zeros{5}, cctrl, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 6, 0, FALSE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 4, 5, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    assert destination != 6;
    assert _Tiles[[destination]].data_type == accumulator_type;
    assert ReadTileElement(destination, 0, 0) == Zeros{PTO_XLEN} +
        (if accumulator_type == TileDataType_FP32 then 0x41300000 else 11);
    assert ReadTileElement(6, 0, 0) == c_before;
end;

func main() => integer
begin
    RunAccumulatorTypeCase(
        TileDataType_FP16, Zeros{5} + 4, TileDataType_FP32, '00');
    RunAccumulatorTypeCase(
        TileDataType_FP16, Zeros{5} + 4, TileDataType_FP32, '01');
    RunAccumulatorTypeCase(
        TileDataType_FP16, Zeros{5} + 4, TileDataType_FP32, '10');
    RunAccumulatorTypeCase(
        TileDataType_FP16, Zeros{5} + 4, TileDataType_FP32, '11');
    RunAccumulatorTypeCase(
        TileDataType_S8, Zeros{5} + 19, TileDataType_S32, '00');
    RunAccumulatorTypeCase(
        TileDataType_U8, Zeros{5} + 27, TileDataType_U32, '00');
    return 0;
end;
