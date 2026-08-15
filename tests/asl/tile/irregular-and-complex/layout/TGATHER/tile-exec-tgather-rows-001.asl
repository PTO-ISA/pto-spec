// PTO-TEST: {"id":"PTO-AVS-TILE-TGATHER-ROWS-001","source":"asl/tile/irregular-and-complex/layout/TGATHER.asl","requirements":["PTO-TGATHER-CONTRACT-001","PTO-INST-TILE-TGATHER"],"kind":"execution","summary":"TGATHER treats every index as a source-row selector at the current column.","pass_condition":"Each destination coordinate copies source[index[r,c],c] rather than a flattened source offset.","related_sources":["asl/tile/model/legality/indexed-rearrangement.asl","asl/tile/model/execution/indexed-rearrangement.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        40, 128, 4, 2, 3, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        41, 128, 2, 2, 2, 2, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        42, 128, 2, 2, 2, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);

    for row = 0 to 2 looplimit 3 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(
                40,
                row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + row * 10 + column);
        end;
    end;
    WriteTileElement(41, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(41, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(41, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(41, 1, 1, Zeros{PTO_XLEN} + 2);

    assert TileOperandsLegal_TGATHER(42, 40, 41);
    TGATHER(42, 40, 41);
    assert ReadTileElement(42, 0, 0) == Zeros{PTO_XLEN} + 20;
    assert ReadTileElement(42, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(42, 1, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(42, 1, 1) == Zeros{PTO_XLEN} + 21;
    return 0;
end;
