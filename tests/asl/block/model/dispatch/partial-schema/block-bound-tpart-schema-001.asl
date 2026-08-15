// PTO-TEST: {"id":"PTO-AVS-BLOCK-TPART-SCHEMA-001","source":"asl/block/model/dispatch/partial-schema.asl","requirements":["PTO-INST-TILE-TPARTADD","PTO-INST-TILE-TPARTMUL","PTO-INST-TILE-TPARTMAX","PTO-INST-TILE-TPARTMIN"],"kind":"boundary","summary":"The TPART family accepts only its closed Local schema","pass_condition":"two origin-anchored Local sources and one new destination are legal while even an all-zero B.DATR carrier is rejected","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}

pure func TPARTSchemaStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '11';
    instruction[24:20] = '10001';
    instruction[31:27] = Zeros{5} + 18;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        32,
        128,
        16,
        4,
        1,
        3,
        TileDataType_S16,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        33,
        128,
        32,
        2,
        1,
        2,
        TileDataType_S16,
        TileLayout_RowMajor,
        TileLocation_Any);
    for column = 0 to 2 do
        WriteTileElement(
            32,
            0,
            column as integer {0..65535},
            Zeros{PTO_XLEN} + column);
    end;
    for column = 0 to 1 do
        WriteTileElement(
            33,
            0,
            column as integer {0..65535},
            Zeros{PTO_XLEN} + column);
    end;

    let started = ExecuteCommandInstruction(TPARTSchemaStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 3);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 4);
    AddBundleTileBinding(
        TRUE,
        0,
        1,
        '0001',
        TRUE,
        TRUE,
        32,
        33,
        TRUE);
    let operation = DecodeTileOperation(
        TileDecode_TEPL,
        Zeros{12} + 0x071)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert SelectedBundleClosedPartialSchemaLegal(operation);

    _BundleDataAttributesPresent = TRUE;
    assert !SelectedBundleClosedPartialSchemaLegal(operation);
    return 0;
end;
