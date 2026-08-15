// PTO-TEST: {"id":"PTO-AVS-TILE-TINSERT-OLD-001","source":"asl/tile/layout-and-rearrangement/layout/TINSERT.asl","requirements":["PTO-TINSERT-CONTRACT-001","PTO-INST-TILE-TINSERT"],"kind":"execution","summary":"TINSERT replaces one window in a snapshotted old destination.","pass_condition":"The insertion window changes while every uncovered old-destination value persists.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 128, 128, 1, 1, 1, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        3, 128, 32, 4, 2, 3, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(
                1,
                row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + 1);
        end;
    end;
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 9);
    TINSERT(3, 1, 2, 1, 1);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(3, 1, 1) == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(3, 1, 2) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
