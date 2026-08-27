// PTO-TEST: {"id":"PTO-AVS-TILE-TSHUF-BFLY-001","source":"asl/tile/layout-and-rearrangement/layout/TSHUF.asl","requirements":["PTO-TSHUF-CONTRACT-001","PTO-INST-TILE-TSHUF"],"kind":"execution","summary":"TSHUF applies BFLY mode independently to active M32 rows.","pass_condition":"Adjacent lanes in each segment exchange their source words.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 4, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_2 = ConfigureCubeTile(2, 128, 4, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_3 = ConfigureCubeTile(3, 128, 4, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    assert configured_1 && configured_2 && configured_3;
    for row = 0 to 3 looplimit 4 do
        WriteTileElement(1, row, 0, Zeros{PTO_XLEN} + (row + 1));
        WriteTileElement(3, row, 0, Zeros{PTO_XLEN} + 0x00000001);
    end;
    assert TileCubeDescriptorLegal(_Tiles[[1]]) &&
        TileCubeDescriptorLegal(_Tiles[[2]]) &&
        TileCubeDescriptorLegal(_Tiles[[3]]);
    assert TileCellRearrangementValidRegionDefined(_Tiles[[1]]);
    assert TileCellRearrangementValidRegionDefined(_Tiles[[3]]);
    assert TileCellRearrangementWordsPerRow(_Tiles[[1]]) == 1;
    assert _Tiles[[3]].valid_columns == 1;
    assert _Tiles[[3]].cube_cell_count == _Tiles[[1]].cube_cell_count;
    TSHUF(2, 1, 3, Zeros{PTO_XLEN} + 0x00000302);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 2, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(2, 3, 0) == Zeros{PTO_XLEN} + 3;
    TSHUF(2, 1, 3, Zeros{PTO_XLEN} + 0x00010200);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 2, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(2, 3, 0) == Zeros{PTO_XLEN} + 3;
    TSHUF(2, 1, 3, Zeros{PTO_XLEN} + 0x00010001);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 2, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(2, 3, 0) == Zeros{PTO_XLEN};
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x00000000);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 0x00000001);
    WriteTileElement(3, 2, 0, Zeros{PTO_XLEN} + 0x00000000);
    WriteTileElement(3, 3, 0, Zeros{PTO_XLEN} + 0x00000001);
    TSHUF(2, 1, 3, Zeros{PTO_XLEN} + 0x00000003);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(2, 2, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(2, 3, 0) == Zeros{PTO_XLEN} + 4;
    assert !TileOperandsLegal_TSHUF(
        2, 1, 3, Zeros{PTO_XLEN} + 0x00000502);
    let configured_4 = ConfigureCubeTile(4, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_5 = ConfigureCubeTile(5, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    let configured_6 = ConfigureCubeTile(6, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 20);
    WriteTileElement(4, 1, 0, Zeros{PTO_XLEN} + 30);
    WriteTileElement(4, 1, 1, Zeros{PTO_XLEN} + 40);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN});
    TSHUF(6, 4, 5, Zeros{PTO_XLEN} + 0x00000102);
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 30;
    assert ReadTileElement(6, 0, 1) == Zeros{PTO_XLEN} + 20;
    assert ReadTileElement(6, 1, 0) == Zeros{PTO_XLEN} + 10;
    assert ReadTileElement(6, 1, 1) == Zeros{PTO_XLEN} + 40;
    let configured_7 = ConfigureCubeTile(7, 128, 3, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_8 = ConfigureCubeTile(8, 128, 3, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_9 = ConfigureCubeTile(9, 128, 3, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(7, 1, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(7, 2, 0, Zeros{PTO_XLEN} + 3);
    for row = 0 to 2 looplimit 3 do
        WriteTileElement(9, row, 0, Zeros{PTO_XLEN} + 1);
    end;
    TSHUF(8, 7, 9, Zeros{PTO_XLEN} + 0x00010200);
    assert ReadTileElement(8, 0, 0) == Zeros{PTO_XLEN};
    assert ReadTileElement(8, 1, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(8, 2, 0) == Zeros{PTO_XLEN} + 2;
    let configured_10 = ConfigureCubeTile(10, 128, 2, 2, TileDataType_U16,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_11 = ConfigureCubeTile(11, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_12 = ConfigureCubeTile(12, 128, 2, 2, TileDataType_U16,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN} + 0x0102);
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN} + 0x0304);
    WriteTileElement(10, 1, 0, Zeros{PTO_XLEN} + 0x0506);
    WriteTileElement(10, 1, 1, Zeros{PTO_XLEN} + 0x0708);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 1, 0, Zeros{PTO_XLEN} + 1);
    TSHUF(12, 10, 11, Zeros{PTO_XLEN} + 0x00000302);
    assert ReadTileElement(12, 0, 0) == Zeros{PTO_XLEN} + 0x0506;
    assert ReadTileElement(12, 0, 1) == Zeros{PTO_XLEN} + 0x0708;
    assert ReadTileElement(12, 1, 0) == Zeros{PTO_XLEN} + 0x0102;
    assert ReadTileElement(12, 1, 1) == Zeros{PTO_XLEN} + 0x0304;
    let configured_13 = ConfigureCubeTile(13, 128, 2, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_14 = ConfigureCubeTile(14, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    let configured_15 = ConfigureCubeTile(15, 128, 2, 4, TileDataType_U8,
        TileLayout_CUBE_M32, TileLocation_Matrix);
    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(13, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(13, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(13, 0, 3, Zeros{PTO_XLEN} + 4);
    WriteTileElement(13, 1, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(13, 1, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(13, 1, 2, Zeros{PTO_XLEN} + 7);
    WriteTileElement(13, 1, 3, Zeros{PTO_XLEN} + 8);
    WriteTileElement(14, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(14, 1, 0, Zeros{PTO_XLEN} + 1);
    TSHUF(15, 13, 14, Zeros{PTO_XLEN} + 0x00000302);
    assert ReadTileElement(15, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert ReadTileElement(15, 0, 1) == Zeros{PTO_XLEN} + 6;
    assert ReadTileElement(15, 1, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(15, 1, 1) == Zeros{PTO_XLEN} + 2;
    return 0;
end;
