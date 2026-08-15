// PTO-TEST: {"id":"PTO-AVS-TILE-TTRANS-RECT-001","source":"asl/tile/layout-and-rearrangement/layout/TTRANS.asl","requirements":["PTO-TTRANS-CONTRACT-001","PTO-INST-TILE-TTRANS"],"kind":"execution","summary":"TTRANS transposes a non-square valid rectangle.","pass_condition":"Every source coordinate is present at the swapped destination coordinate.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 128, 64, 2, 3, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(
                1,
                row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + row * 3 + column + 1);
        end;
    end;
    TTRANS(2, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(2, 2, 0) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
