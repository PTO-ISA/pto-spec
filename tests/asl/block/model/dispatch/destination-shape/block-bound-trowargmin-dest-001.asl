// PTO-TEST: {"id":"PTO-AVS-BLOCK-TROWARGMIN-DEST-001","source":"asl/block/model/dispatch/destination-shape.asl","requirements":["PTO-TROWARGMIN-CONTRACT-001"],"kind":"boundary","summary":"TROWARGMIN allocates a one-column U32 destination independently of its source DataType.","pass_condition":"The renamed destination has U32 type, source.ValidRow valid rows, one valid and physical column, and sufficient capacity-derived rows.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/tile/reduce-and-expand/row-reduction/TROWARGMIN.asl"]}
pure func TROWARGMINShapeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '01101';
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        4,
        4,
        2,
        3,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + column);
        end;
    end;

    let started = ExecuteCommandInstruction(TROWARGMINShapeStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '1111',
        TRUE,
        FALSE,
        1,
        0,
        TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x04D)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let resolved = ResolveBundleTileDestinationsForOperation(operation);
    assert resolved;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U32;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == 1;
    assert _Tiles[[destination]].columns == 1;
    assert _Tiles[[destination]].rows >= 2;
    return 0;
end;
