// PTO-TEST: {"id":"PTO-AVS-BLOCK-MATRIX-DEST-SHAPE-001","source":"asl/block/model/dispatch/destination-shape.asl","requirements":["PTO-B-FPATR-MATRIX-POSTPROCESS-001"],"kind":"boundary","summary":"matrix destination preflight derives D RowMaxOut and GroupMaxOut independently","pass_condition":"a 1 by 8 product allocates one 1 by 8 D and two 1 by 1 auxiliary descriptors","related_sources":["asl/block/model/dispatch/cube-tmatmul.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 8, 1, 8, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(2, 0, column, Zeros{PTO_XLEN});
    end;
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN});

    var start = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, '0001', TRUE, TRUE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', TRUE, FALSE, 3, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 2, 1, '1111', FALSE, FALSE, 0, 0, TRUE);

    let resolved = ResolveBundleTMATMULDestination(
        1, 8, TileDataType_FP32);
    assert resolved;
    let destination = BundleMatrixDestinationAt(0);
    let row_max = BundleMatrixDestinationAt(1);
    let group_max = BundleMatrixDestinationAt(2);
    assert destination == 0;
    assert row_max == 16;
    assert group_max == 32;
    assert _BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert _Tiles[[destination]].valid_columns == 8;
    assert _Tiles[[row_max]].valid_columns == 1;
    assert _Tiles[[group_max]].valid_columns == 1;
    return 0;
end;
