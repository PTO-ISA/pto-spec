// PTO-TEST: {"id":"PTO-AVS-BLOCK-TROWSUM-SCHEMA-001","source":"asl/block/model/dispatch/reduction-schema.asl","requirements":["PTO-TROWSUM-CONTRACT-001"],"kind":"boundary","summary":"TROWSUM accepts exactly one terminating Local destination/source binding and no scalar binding.","pass_condition":"The complete U64 reduction schema is legal before a B.IOR binding is added and illegal afterward.","related_sources":["asl/tile/reduce-and-expand/row-reduction/TROWSUM.asl"]}
pure func TROWSUMSchemaStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00000';
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

    let started = ExecuteCommandInstruction(TROWSUMSchemaStart(), 32);
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
        Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert TileOperationUsesClosedReductionSchema(operation);
    assert SelectedBundleClosedReductionSchemaLegal(operation);

    SetBundleScalarBinding(0, 0, 0, 0, 0, 0);
    assert !SelectedBundleClosedReductionSchemaLegal(operation);
    return 0;
end;
