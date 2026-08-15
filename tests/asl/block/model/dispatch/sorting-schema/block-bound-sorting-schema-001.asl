// PTO-TEST: {"id":"PTO-AVS-BLOCK-SORT-SCHEMA-001","source":"asl/block/model/dispatch/sorting-schema.asl","requirements":[],"kind":"boundary","summary":"sorting bundle schemas distinguish TSORT dimensions from TMRGSORT source-derived shape","pass_condition":"TSORT accepts omitted or zero LB0 and rejects widths above 64, while TMRGSORT rejects every explicit dimension","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/block/model/dispatch/tile-execution.asl"]}

pure func SortingSchemaStart(function: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = function;
    instruction[31:27] = Zeros{5} + 1;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        32, 128, 8, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    for column = 0 to 3 do
        WriteTileElement(32, 0, column, Zeros{PTO_XLEN});
    end;
    let tsort_started = ExecuteCommandInstruction(
        SortingSchemaStart('01100'), 32);
    assert tsort_started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE, 0, 1, '0001', TRUE, FALSE, 32, 0, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '0001', FALSE, FALSE, 0, 0, TRUE);

    let tsort = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x06c)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedSortingSchemaLegal(tsort);
    _BundleDimensionPresent[[0]] = TRUE;
    _BundleDimensions[[0]] = Zeros{PTO_XLEN};
    assert SelectedBundleClosedSortingSchemaLegal(tsort);
    _BundleDimensions[[0]] = Zeros{PTO_XLEN} + 65;
    assert !SelectedBundleClosedSortingSchemaLegal(tsort);

    ResetProfileState();
    ConfigureTile(
        32, 128, 16, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        33, 128, 16, 2, 1, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    for column = 0 to 1 do
        WriteTileElement(32, 0, column, Zeros{PTO_XLEN});
        WriteTileElement(33, 0, column, Zeros{PTO_XLEN});
    end;
    let tmrgsort_started = ExecuteCommandInstruction(
        SortingSchemaStart('01101'), 32);
    assert tmrgsort_started == CommandExecution_Executed;
    AddBundleTileBinding(
        TRUE, 0, 1, '0001', TRUE, TRUE, 32, 33, TRUE);
    let tmrgsort = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x06d)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedSortingSchemaLegal(tmrgsort);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    assert !SelectedBundleClosedSortingSchemaLegal(tmrgsort);
    return 0;
end;
