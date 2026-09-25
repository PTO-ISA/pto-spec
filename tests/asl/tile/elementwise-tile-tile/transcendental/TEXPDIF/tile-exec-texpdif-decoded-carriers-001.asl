// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-DECODED-CARRIERS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"execution","summary":"decoded TEXPDIF interprets independent U16 and S16 source carriers as FP16 and allocates an FP32 destination","pass_condition":"the decoded operation publishes the exact widen-first mixed results into an independently shaped FP32 destination, preserves both source descriptors, status flags and selected padding","related_sources":["asl/block/model/dispatch/tile-schema.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/expdif.asl"]}
pure func TexdifFP16Start() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[24:20] = '11101';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP16);
    return instruction;
end;

pure func TexdifFP16DATR(data_type: bits(5), data_layout: bits(5),
                         pad_value: bits(2)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = pad_value;
    instruction[24:20] = data_type;
    instruction[11:7] = data_layout;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 32, 2, 1, 2,
        TileDataType_U16, TileLayout_RowMajor);
    ConfigureTile(2, 128, 32, 2, 1, 2,
        TileDataType_S16, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x2000);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x0001);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});

    let started = ExecuteCommandInstruction(TexdifFP16Start(), 32);
    assert started == CommandExecution_Executed;
    let attributes = ExecuteCommandInstruction(
        TexdifFP16DATR(TileDataTypeToEncoding(TileDataType_FP32),
            Zeros{5}, '00'), 32);
    assert attributes == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111',
        TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert _Tiles[[destination]].layout == TileLayout_RowMajor;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].columns == 2;
    assert _Tiles[[destination]].rows == 16;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f810100;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x402df854;
    assert TileElementDefined(destination, 1, 0);
    assert ReadTileElement(destination, 1, 0) == Zeros{PTO_XLEN};
    assert _Tiles[[1]].data_type == TileDataType_U16;
    assert _Tiles[[2]].data_type == TileDataType_S16;
    let (expected0, flags0) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x2000, Zeros{PTO_XLEN} + 0x0001);
    let (expected1, flags1) = TileExpdifValueWithTypesAndFlags(
        TileDataType_FP16, TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x3c00, Zeros{PTO_XLEN});
    assert expected0 == ReadTileElement(destination, 0, 0);
    assert expected1 == ReadTileElement(destination, 0, 1);
    assert NumericStatusFlags() == (flags0 OR flags1);
    return 0;
end;
