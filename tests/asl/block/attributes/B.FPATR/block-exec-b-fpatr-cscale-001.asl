// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-CSCALE-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-B-DATR-MATRIX-ACC-CONTROL-001","PTO-CUBE-CSCALE-001","PTO-CUBE-INTERNAL-ACCUMULATOR-001","PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"Decoded CScale transforms explicit FP32 C identically across final/raw output and transparent-cache hint controls.","pass_condition":"two-row TMATMUL.ACC runs for CCTRL 00, 01, 10, and 11 all scale C values 4.0 and 8.0 by row exponents one and two to FP32 2.0; 00 equals 10 and 01 equals 11.","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl","asl/tile/model/execution/cube.asl","asl/tile/model/execution/internal-accumulator.asl"]}

func RunCScaleControl(cctrl: bits(2)) => Word
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 2, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let c_ready = ConfigureCubeTileForMask(3, 128, 2, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let scale_ready = ConfigureCubeTileForMask(4, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready && c_ready && scale_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x40800000);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 0x41000000);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 1, 0, Zeros{PTO_XLEN} + 2);
    MarkTileValidRegionDefined(4);
    assert _Tiles[[4]].contents_defined;

    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    let fpatr = ExecuteCommandInstruction(
        Zeros{64} + 0x00002223, 32);
    assert started == CommandExecution_Executed;
    assert fpatr == CommandExecution_Executed;
    assert _BundleFixedPointAttributes.c_scale_en;
    SetBundleDataAttributeState(
        Zeros{5} + 4, Zeros{5}, cctrl, Zeros{3}, Zeros{3},
        FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);

    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 3, 1, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 2, 4, TRUE);

    let decoded = DecodeTileOperation(
        TileDecode_CUBE, BundleOperationDecodeCode(_BundleOperation));
    assert decoded != PTO_TILE_OPERATION_COUNT;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleMatrixDynamicBindingsComplete(
        operation, 2, TileDataType_FP16,
        TileDataType_FP16, 0);
    assert _Tiles[[4]].contents_defined;
    assert TileCubeDescriptorLegal(_Tiles[[4]]);
    assert _Tiles[[4]].valid_rows == 2;
    assert _Tiles[[4]].valid_columns == 1;
    assert _Tiles[[4]].data_type == TileDataType_U8;
    assert _Tiles[[4]].layout == TileLayout_CUBE_M32;
    assert _Tiles[[4]].location == TileLocation_Matrix;
    assert TileMatrixLocalCScaleSchemaLegal(4, 2);
    assert BundleMatrixLocalMathematicalSourcesLegal(
        2, TileDataType_FP16, TileDataType_FP16,
        2, 1, 1, 0, TileDataType_FP32, 128);
    assert BundleMatrixCScaleDestinationIndicesDistinct(3);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = BundleMatrixDestinationAt(0);
    assert destination != 3 && destination != 4;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x40000000;
    assert ReadTileElement(destination, 1, 0) ==
        Zeros{PTO_XLEN} + 0x40000000;
    return ReadTileElement(destination, 0, 0);
end;

func main() => integer
begin
    let final_without_hint = RunCScaleControl('00');
    let raw_without_hint = RunCScaleControl('01');
    let final_with_hint = RunCScaleControl('10');
    let raw_with_hint = RunCScaleControl('11');
    assert final_without_hint == final_with_hint;
    assert raw_without_hint == raw_with_hint;
    return 0;
end;
