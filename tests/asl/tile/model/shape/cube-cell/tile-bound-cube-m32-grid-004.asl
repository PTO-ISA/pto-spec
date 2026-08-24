// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-M32-GRID-004","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-MATRIX-SCALE-CELL-001"],"kind":"boundary","summary":"Generic CUBE_M32 scale storage uses a two-dimensional 128-byte CellReg grid.","pass_condition":"MX G5 N33 and HiF4 G2 N33 each require four cells in K-fast and N-slow order, with partial final group and row tails outside the valid region.","related_sources":["asl/tile/model/state/allocation.asl"]}

func main() => integer
begin
    ResetProfileState();

    let mx = ConfigureCubeTileForMask(
        1, 512, 33, 5, TileDataType_E8M0,
        TileLayout_CUBE_M32, TileLocation_Matrix, '1000');
    assert mx;
    assert _Tiles[[1]].rows == 64;
    assert _Tiles[[1]].columns == 8;
    assert _Tiles[[1]].cube_k_repeat == 2;
    assert _Tiles[[1]].cube_n_repeat == 2;
    assert _Tiles[[1]].cube_cell_count == 4;
    assert _Tiles[[1]].cube_storage_bytes == 512;
    assert TileCubePayloadIndex(_Tiles[[1]], 0, 0) == 0;
    assert TileCubePayloadIndex(_Tiles[[1]], 0, 4) == 128;
    assert TileCubePayloadIndex(_Tiles[[1]], 32, 0) == 256;
    assert TileCubePayloadIndex(_Tiles[[1]], 32, 4) == 384;

    let hif = ConfigureCubeTileForMask(
        2, 512, 33, 2, TileDataType_U32,
        TileLayout_CUBE_M32, TileLocation_Matrix, '1000');
    assert hif;
    assert _Tiles[[2]].rows == 64;
    assert _Tiles[[2]].columns == 2;
    assert _Tiles[[2]].cube_k_repeat == 2;
    assert _Tiles[[2]].cube_n_repeat == 2;
    assert _Tiles[[2]].cube_cell_count == 4;
    assert _Tiles[[2]].cube_storage_bytes == 512;
    assert TileCubePayloadIndex(_Tiles[[2]], 0, 0) == 0;
    assert TileCubePayloadIndex(_Tiles[[2]], 0, 1) == 32;
    assert TileCubePayloadIndex(_Tiles[[2]], 32, 0) == 64;
    assert TileCubePayloadIndex(_Tiles[[2]], 32, 1) == 96;
    return 0;
end;
