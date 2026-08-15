// PTO-TEST: {"id":"PTO-AVS-TILE-TSORT-LEGALITY-001","source":"asl/tile/model/legality/sorting.asl","requirements":["PTO-INST-TILE-TSORT"],"kind":"boundary","summary":"TSORT requires matching FP value shapes and a distinct U32 index destination","pass_condition":"the canonical three-Tile configuration is legal and an incorrect index type is rejected","related_sources":[]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        20, 128, 8, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        21, 128, 8, 4, 1, 4,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        22, 128, 8, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    for column = 0 to 3 do
        WriteTileElement(
            22,
            0,
            column,
            Zeros{PTO_XLEN} + column);
    end;

    assert TileOperandsLegal_TSORT(20, 21, 22, 3, FALSE);
    _Tiles[[21]].data_type = TileDataType_FP32;
    assert !TileOperandsLegal_TSORT(20, 21, 22, 3, FALSE);
    return 0;
end;
