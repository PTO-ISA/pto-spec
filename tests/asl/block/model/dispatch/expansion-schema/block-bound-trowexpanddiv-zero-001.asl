// PTO-TEST: {"id":"PTO-AVS-BLOCK-TROWEXPANDDIV-ZERO-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-TROWEXPANDDIV-CONTRACT-001"],"kind":"boundary","summary":"TROWEXPANDDIV rejects a zero integer broadcast denominator before allocation.","pass_condition":"The complete U8 schema is legal with nonzero denominators and becomes illegal when one selected row denominator is zero.","related_sources":["asl/tile/reduce-and-expand/row-expansion/TROWEXPANDDIV.asl"]}
pure func TROWEXPANDDIVSchemaStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '01000';
    instruction[31:27] = Zeros{5} + 27;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1,
        128,
        32,
        4,
        2,
        3,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        128,
        1,
        2,
        1,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 8);
        end;
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 2);
    end;

    let started = ExecuteCommandInstruction(
        TROWEXPANDDIVSchemaStart(),
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
        TRUE,
        1,
        2,
        TRUE);

    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x048)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedExpansionSchemaLegal(operation);

    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    assert !SelectedBundleClosedExpansionSchemaLegal(operation);
    return 0;
end;
