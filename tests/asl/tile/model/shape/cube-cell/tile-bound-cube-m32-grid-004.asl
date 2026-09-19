// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-M32-GRID-004","source":"asl/tile/model/shape/cube-cell.asl","requirements":["PTO-CUBE-MATRIX-SCALE-CELL-001"],"kind":"boundary","summary":"Generic CUBE_M32 scale storage uses one 32-row physical block and a two-dimensional 128-byte CellReg grid.","pass_condition":"MX G5 and HiF4 G2 retain multi-column K-fast Cell repetition with NRepeat=1; valid row 32 passes and row 33 is rejected.","related_sources":["asl/tile/model/state/allocation.asl"]}

func main() => integer
begin
    ResetProfileState();

    let mx = ConfigureCubeTileForMask(
        1, 512, 32, 5, TileDataType_E8M0,
        TileLayout_CUBE_M32, '1000');
    assert mx;
    assert _Tiles[[1]].rows == 32;
    assert _Tiles[[1]].columns == 8;
    assert _Tiles[[1]].cube_k_repeat == 2;
    assert _Tiles[[1]].cube_n_repeat == 1;
    assert _Tiles[[1]].cube_cell_count == 2;
    assert _Tiles[[1]].cube_storage_bytes == 256;
    assert TileCubePayloadIndex(_Tiles[[1]], 0, 0) == 0;
    assert TileCubePayloadIndex(_Tiles[[1]], 0, 4) == 128;
    assert !TileCubeDescriptorShapeLegal(
        512, 33, 5, TileDataType_E8M0, TileLayout_CUBE_M32);

    let hif = ConfigureCubeTileForMask(
        2, 512, 32, 2, TileDataType_U32,
        TileLayout_CUBE_M32, '1000');
    assert hif;
    assert _Tiles[[2]].rows == 32;
    assert _Tiles[[2]].columns == 2;
    assert _Tiles[[2]].cube_k_repeat == 2;
    assert _Tiles[[2]].cube_n_repeat == 1;
    assert _Tiles[[2]].cube_cell_count == 2;
    assert _Tiles[[2]].cube_storage_bytes == 256;
    assert TileCubePayloadIndex(_Tiles[[2]], 0, 0) == 0;
    assert TileCubePayloadIndex(_Tiles[[2]], 0, 1) == 32;
    return 0;
end;
