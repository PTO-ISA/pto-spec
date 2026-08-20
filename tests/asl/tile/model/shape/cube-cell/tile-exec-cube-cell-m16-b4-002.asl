// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-CELL-M16-B4-002","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-CELL-STATE-001"],"kind":"execution","summary":"CUBE M16 b4 uses the assigned two-word interleave","pass_condition":"logical columns map to physical nibble positions 0 1 2 3 8 9 10 11 4 5 6 7 12 13 14 15","related_sources":[]}
func main() => integer
begin
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 0) == 0;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 1) == 1;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 2) == 2;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 3) == 3;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 4) == 8;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 5) == 9;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 6) == 10;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 7) == 11;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 8) == 4;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 9) == 5;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 10) == 6;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 11) == 7;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 12) == 12;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 13) == 13;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 14) == 14;
    assert TileCubeCellElementIndex(TileLayout_CUBE_M16,
        TileDataType_E2M1X2, 0, 15) == 15;
    return 0;
end;
