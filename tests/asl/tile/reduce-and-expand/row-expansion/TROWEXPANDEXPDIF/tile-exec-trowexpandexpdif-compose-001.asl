// PTO-TEST: {"id":"PTO-AVS-TILE-TROWEXPANDEXPDIF-COMPOSE-001","source":"asl/tile/reduce-and-expand/row-expansion/TROWEXPANDEXPDIF.asl","requirements":["PTO-TROWEXPANDEXPDIF-CONTRACT-001","PTO-INST-TILE-TROWEXPANDEXPDIF"],"kind":"execution","summary":"TROWEXPANDEXPDIF applies its exact EXPDIF semantics with row broadcasting.","pass_condition":"The selected element equals the typed EXPDIF result and every source remains persistent.","related_sources":["asl/tile/model/execution/expansion.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 8, 4, 2, 3, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(1, row, column, Zeros{PTO_XLEN} + 0x40000000);
        end;
    end;
    ConfigureTile(
        2, 128, 32, 1,
        2, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 0x3f800000);
    end;
    ConfigureTile(
        3, 128, 8, 4, 2, 3, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    let (difference, -) = TileProfileBinaryWithFlags(
        TileBinary_SUB,
        TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x40000000,
        Zeros{PTO_XLEN} + 0x3f800000);
    let (handled, special_result, -) = TileSFUUnarySpecialValue(
        TileUnary_EXP,
        TileDataType_FP32,
        difference);
    var expected = special_result;
    if !handled then
        let (profile_result, -) = TileProfileUnary(
            TileUnary_EXP,
            TileDataType_FP32,
            difference);
        expected = profile_result;
    end;
    ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Row,
        3,
        1,
        2);
    assert ReadTileElement(3, 1, 2) == expected;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 0x3f800000;
    return 0;
end;
