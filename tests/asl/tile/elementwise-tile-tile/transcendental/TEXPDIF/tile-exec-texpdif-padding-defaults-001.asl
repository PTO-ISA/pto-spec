// PTO-TEST: {"id":"PTO-AVS-TILE-TEXPDIF-PADDING-DEFAULTS-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl","requirements":["PTO-INST-TILE-TEXPDIF","PTO-TEXPDIF-CONTRACT-001"],"kind":"execution","summary":"TEXPDIF applies all padding codes and resolves optional DATR and dimensions","pass_condition":"omitted B.DATR selects FP16 and Null padding; DTYPE_NONE inherits FP16; Zero, Max, Min, and Null padding and omitted LB1/LB2 defaults match the contract","related_sources":["asl/block/model/dispatch/destination-operation.asl","asl/block/model/dispatch/destination-shape.asl","asl/tile/model/definedness/elements.asl","asl/tile/model/execution/expdif.asl"]}
pure func TexdifPaddingStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[24:20] = '11101';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP16);
    return instruction;
end;

pure func TexdifPaddingDATR(pad_value: bits(2)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[28:27] = pad_value;
    instruction[24:20] = Zeros{5} + 31;
    instruction[11:7] = Zeros{5};
    return instruction;
end;

func RunTexdifPaddingCase(
    datr_present: boolean,
    pad_value: bits(2),
    expected_defined: boolean,
    expected_value: bits(16)) => boolean
begin
    ResetProfileState();
    ConfigureTile(1, 128, 16, 2, 1, 2,
        TileDataType_FP16, TileLayout_RowMajor);
    ConfigureTile(2, 128, 16, 2, 1, 2,
        TileDataType_FP16, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});

    let start_result = ExecuteCommandInstruction(
        TexdifPaddingStart(), 32);
    assert start_result == CommandExecution_Executed;
    if datr_present then
        let datr_result = ExecuteCommandInstruction(
            TexdifPaddingDATR(pad_value), 32);
        assert datr_result == CommandExecution_Executed;
    end;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111',
        TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP16;
    assert _Tiles[[destination]].valid_rows == 1;
    assert _Tiles[[destination]].valid_columns == 2;
    assert _Tiles[[destination]].rows >
        _Tiles[[destination]].valid_rows;
    assert TileElementDefined(destination, 1, 0) == expected_defined;
    if expected_defined then
        assert ReadTileElement(destination, 1, 0)[15:0] == expected_value;
    end;
    assert _Tiles[[1]].data_type == TileDataType_FP16;
    assert _Tiles[[2]].data_type == TileDataType_FP16;
    return TRUE;
end;

func main() => integer
begin
    let omitted_datr = RunTexdifPaddingCase(
        FALSE, '11', FALSE, Zeros{16});
    let zero = RunTexdifPaddingCase(
        TRUE, '00', TRUE, Zeros{16});
    let maximum = RunTexdifPaddingCase(
        TRUE, '01', TRUE, Zeros{16} + 0x7bff);
    let minimum = RunTexdifPaddingCase(
        TRUE, '10', TRUE, Zeros{16} + 0xfbff);
    let null_padding = RunTexdifPaddingCase(
        TRUE, '11', FALSE, Zeros{16});
    assert omitted_datr && zero && maximum && minimum && null_padding;
    return 0;
end;
