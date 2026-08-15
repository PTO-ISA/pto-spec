// PTO-TEST: {"id":"PTO-AVS-TILE-TEXTRACT-WINDOW-001","source":"asl/tile/layout-and-rearrangement/layout/TEXTRACT.asl","requirements":["PTO-TEXTRACT-CONTRACT-001","PTO-INST-TILE-TEXTRACT"],"kind":"execution","summary":"TEXTRACT copies the rectangular source window selected by two offsets.","pass_condition":"The destination coordinates equal the matching offset source coordinates.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        1, 128, 32, 4, 3, 4, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 128, 32, 4, 2, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 2 looplimit 3 do
        for column = 0 to 3 looplimit 4 do
            WriteTileElement(
                1,
                row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} + row * 4 + column);
        end;
    end;
    TEXTRACT(2, 1, 1, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 10;
    return 0;
end;
