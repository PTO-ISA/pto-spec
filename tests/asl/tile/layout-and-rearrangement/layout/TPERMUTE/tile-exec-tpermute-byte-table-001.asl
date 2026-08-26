// PTO-TEST: {"id":"PTO-AVS-TILE-TPERMUTE-BYTE-TABLE-001","source":"asl/tile/layout-and-rearrangement/layout/TPERMUTE.asl","requirements":["PTO-TPERMUTE-CONTRACT-001","PTO-INST-TILE-TPERMUTE"],"kind":"execution","summary":"TPERMUTE selects valid M32 output bytes from two source rows.","pass_condition":"Each valid destination byte follows its independent U8 table index.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_2 = ConfigureCubeTile(2, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_3 = ConfigureCubeTile(3, 128, 1, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_4 = ConfigureCubeTile(4, 128, 1, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x04030201);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x08070605);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x00000000);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 0x00000004);
    WriteTileElement(4, 0, 2, Zeros{PTO_XLEN} + 0x00000001);
    WriteTileElement(4, 0, 3, Zeros{PTO_XLEN} + 0x00000005);
    TPERMUTE(3, 1, 2, 4);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x06020501;
    let configured_5 = ConfigureCubeTile(5, 128, 1, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_6 = ConfigureCubeTile(6, 128, 1, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_7 = ConfigureCubeTile(7, 128, 1, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_8 = ConfigureCubeTile(8, 128, 1, 8, TileDataType_U8,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 0x04030201);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 0x08070605);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 0x14131211);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 0x18171615);
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(8, 0, column, Zeros{PTO_XLEN} + (column + 8));
    end;
    assert TileOperandsLegal_TPERMUTE(7, 5, 6, 8);
    TPERMUTE(7, 5, 6, 8);
    assert ReadTileElement(7, 0, 0) == Zeros{PTO_XLEN} + 0x14131211;
    assert ReadTileElement(7, 0, 1) == Zeros{PTO_XLEN} + 0x18171615;
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 0x10);
    assert !TileOperandsLegal_TPERMUTE(7, 5, 6, 8);
    // A partial M32 byte row consumes only its three valid index bytes.  The
    // fourth physical/padding byte is deliberately left undefined and is not
    // consulted by legality or execution.
    let configured_9 = ConfigureCubeTile(9, 128, 1, 3, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_10 = ConfigureCubeTile(10, 128, 1, 3, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_11 = ConfigureCubeTile(11, 128, 1, 3, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_12 = ConfigureCubeTile(12, 128, 1, 3, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(9, 0, 0, Zeros{PTO_XLEN} + 0x01);
    WriteTileElement(9, 0, 1, Zeros{PTO_XLEN} + 0x02);
    WriteTileElement(9, 0, 2, Zeros{PTO_XLEN} + 0x03);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x11);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 0x12);
    WriteTileElement(10, 0, 2, Zeros{PTO_XLEN} + 0x13);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 0x05);
    WriteTileElement(12, 0, 2, Zeros{PTO_XLEN} + 0x06);
    assert TileOperandsLegal_TPERMUTE(11, 9, 10, 12);
    TPERMUTE(11, 9, 10, 12);
    assert ReadTileElement(11, 0, 0) == Zeros{PTO_XLEN} + 0x01;
    assert ReadTileElement(11, 0, 1) == Zeros{PTO_XLEN} + 0x12;
    assert ReadTileElement(11, 0, 2) == Zeros{PTO_XLEN} + 0x13;
    assert !TileCellRearrangementByteDefined(_Tiles[[12]], 0, 3);
    return 0;
end;
