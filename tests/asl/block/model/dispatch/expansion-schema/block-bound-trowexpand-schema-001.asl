// PTO-TEST: {"id":"PTO-AVS-BLOCK-TROWEXPAND-SCHEMA-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-TROWEXPAND-CONTRACT-001"],"kind":"boundary","summary":"TROWEXPAND accepts one terminating destination and one one-column source only.","pass_condition":"The exact COPY schema is legal with source0 alone and rejects an added source1 before allocation.","related_sources":["asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl"]}
pure func TROWEXPANDSchemaStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00100';
    instruction[31:27] = Zeros{5} + 24;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        16,
        1,
        2,
        1,
        TileDataType_U64,
        TileLayout_RowMajor,
        TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(1, row, 0, Zeros{PTO_XLEN} + row);
    end;

    let started = ExecuteCommandInstruction(
        TROWEXPANDSchemaStart(),
        32);
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
        Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationUsesClosedExpansionSchema(operation);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);

    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = 1;
    assert !SelectedBundleClosedExpansionSchemaLegal(operation);
    return 0;
end;
