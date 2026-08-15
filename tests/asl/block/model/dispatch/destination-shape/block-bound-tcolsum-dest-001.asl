// PTO-TEST: {"id":"PTO-AVS-BLOCK-TCOLSUM-DEST-001","source":"asl/block/model/dispatch/destination-shape.asl","requirements":["PTO-TCOLSUM-CONTRACT-001"],"kind":"boundary","summary":"TCOLSUM allocates one valid destination row while preserving source column geometry.","pass_condition":"The renamed destination remains U64 with ValidRow one, source.ValidCol valid columns, and the source physical column count.","related_sources":["asl/block/model/dispatch/reduction-schema.asl","asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl"]}
pure func TCOLSUMShapeStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '10000';
    instruction[31:27] = Zeros{5} + 24;
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
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 1);
        end;
    end;

    let started = ExecuteCommandInstruction(TCOLSUMShapeStart(), 32);
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
        Zeros{12} + 0x050)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedReductionSchemaLegal(operation);
    let resolved = ResolveBundleTileDestinationsForOperation(operation);
    assert resolved;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_U64;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 3;
    assert _Tiles[[destination]].columns == 4;
    assert _Tiles[[destination]].rows >= 1;
    return 0;
end;
