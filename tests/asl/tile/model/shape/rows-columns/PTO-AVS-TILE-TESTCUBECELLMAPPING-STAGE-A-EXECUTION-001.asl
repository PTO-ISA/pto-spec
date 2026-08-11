// PTO-TEST: {"id":"PTO-AVS-TILE-TESTCUBECELLMAPPING-STAGE-A-EXECUTION-001","source":"asl/tile/model/shape/rows-columns.asl","requirements":[],"kind":"state-transition","summary":"Stage A CUBE CELL geometry, indexing, capacity, tails, and persistent valid-region updates","pass_condition":"all dtype-width, interleave, repeat-order, capacity, and descriptor-persistence assertions hold","related_sources":[]}

pure func CubeStageAType(width_index: integer {0..3}) => TileDataType
begin
    case width_index of
        when 0 => return TileDataType_FP32;
        when 1 => return TileDataType_FP16;
        when 2 => return TileDataType_U8;
        when 3 => return TileDataType_U4X2;
    end;
end;

func TestCubeStageAWidthsAndShapes()
begin
    assert TileCubeKPerCell(TileLayout_CUBE_M32,
        TileDataType_FP32) == 1;
    assert TileCubeKPerCell(TileLayout_CUBE_M32,
        TileDataType_FP16) == 2;
    assert TileCubeKPerCell(TileLayout_CUBE_M32,
        TileDataType_U8) == 4;
    assert TileCubeKPerCell(TileLayout_CUBE_M32,
        TileDataType_U4X2) == 8;
    assert TileCubeKPerCell(TileLayout_CUBE_M16,
        TileDataType_FP32) == 2;
    assert TileCubeKPerCell(TileLayout_CUBE_M16,
        TileDataType_FP16) == 4;
    assert TileCubeKPerCell(TileLayout_CUBE_M16,
        TileDataType_U8) == 8;
    assert TileCubeKPerCell(TileLayout_CUBE_M16,
        TileDataType_U4X2) == 16;
    assert TileCubeKPerCell(TileLayout_CUBE_N8,
        TileDataType_FP32) == 4;
    assert TileCubeKPerCell(TileLayout_CUBE_N8,
        TileDataType_FP16) == 8;
    assert TileCubeKPerCell(TileLayout_CUBE_N8,
        TileDataType_U8) == 16;
    assert TileCubeKPerCell(TileLayout_CUBE_N8,
        TileDataType_U4X2) == 32;
    assert TileCubeKPerCell(TileLayout_CUBE_M32, TileDataType_FP64) == 0;

    for width_index = 0 to 3 looplimit 4 do
        let data_type = CubeStageAType(width_index);
        let width_m32 = TileCubeKPerCell(TileLayout_CUBE_M32, data_type);
        let width_m16 = TileCubeKPerCell(TileLayout_CUBE_M16, data_type);
        let width_n8 = TileCubeKPerCell(TileLayout_CUBE_N8, data_type);
        assert TileCubeStorageRows(TileLayout_CUBE_M32,
            1, data_type) == 32;
        assert TileCubeStorageColumns(TileLayout_CUBE_M32,
            width_m32 + 1, data_type) == width_m32 * 2;
        assert TileCubeNRepeat(TileLayout_CUBE_M32,
            width_m32 + 1, data_type) == 1;
        assert TileCubeStorageRows(TileLayout_CUBE_M16,
            1, data_type) == 16;
        assert TileCubeStorageColumns(TileLayout_CUBE_M16,
            width_m16 + 1, data_type) == width_m16 * 2;
        assert TileCubeNRepeat(TileLayout_CUBE_M16,
            width_m16 + 1, data_type) == 1;
        assert TileCubeStorageRows(TileLayout_CUBE_N8,
            width_n8 + 1, data_type) == width_n8 * 2;
        assert TileCubeStorageColumns(TileLayout_CUBE_N8,
            9, data_type) == 16;
    end;
end;

func TestCubeStageAM16B4Interleave()
begin
    let layout = TileLayout_CUBE_M16;
    let data_type = TileDataType_U4X2;
    assert TileCubeCellElementIndex(layout, data_type, 0, 0) == 0;
    assert TileCubeCellElementIndex(layout, data_type, 0, 1) == 1;
    assert TileCubeCellElementIndex(layout, data_type, 0, 2) == 2;
    assert TileCubeCellElementIndex(layout, data_type, 0, 3) == 3;
    assert TileCubeCellElementIndex(layout, data_type, 0, 4) == 8;
    assert TileCubeCellElementIndex(layout, data_type, 0, 5) == 9;
    assert TileCubeCellElementIndex(layout, data_type, 0, 6) == 10;
    assert TileCubeCellElementIndex(layout, data_type, 0, 7) == 11;
    assert TileCubeCellElementIndex(layout, data_type, 0, 8) == 4;
    assert TileCubeCellElementIndex(layout, data_type, 0, 9) == 5;
    assert TileCubeCellElementIndex(layout, data_type, 0, 10) == 6;
    assert TileCubeCellElementIndex(layout, data_type, 0, 11) == 7;
    assert TileCubeCellElementIndex(layout, data_type, 0, 12) == 12;
    assert TileCubeCellElementIndex(layout, data_type, 0, 13) == 13;
    assert TileCubeCellElementIndex(layout, data_type, 0, 14) == 14;
    assert TileCubeCellElementIndex(layout, data_type, 0, 15) == 15;
    assert TileCubePayloadIndex(layout, data_type, 1,
        1, 4) == 24;
end;

func TestCubeStageABRepeatsAndTails()
begin
    let layout = TileLayout_CUBE_N8;
    let data_type = TileDataType_FP16;
    ResetProfileState();
    assert TileCapacityIsLegal(1024);
    assert TileCubeKPerCell(layout, data_type) == 8;
    assert TileCubeStorageRows(layout, 13,
        data_type) == 16;
    assert TileCubeStorageColumns(layout, 19,
        data_type) == 24;
    assert TileCubeKRepeat(layout, 13, 19,
        data_type) == 2;
    assert TileCubeNRepeat(layout, 19, data_type) == 3;
    assert TileCubeCellCount(layout, 13, 19,
        data_type) == 6;
    assert TileCubeRequiredBytes(layout, 13, 19,
        data_type) == 768;
    assert TileCubeDescriptorShapeLegal(1024, 13, 19, data_type,
        layout);
    assert !TileCubeDescriptorShapeLegal(512, 13, 19, data_type,
        layout);
    assert TileCubeStorageRows(layout, 13,
        data_type) == 16;
    assert TileCubeStorageColumns(layout, 19,
        data_type) == 24;
    assert TileCubeKRepeat(layout, 13, 19, data_type) == 2;
    assert TileCubeNRepeat(layout, 19, data_type) == 3;
    assert TileCubeCellCount(layout, 13, 19,
        data_type) == 6;
    // K-repeat is the fast CELL dimension; N-repeat is slow.
    assert TileCubePayloadIndex(layout, data_type, 2,
        8, 0) == 64;
    assert TileCubePayloadIndex(layout, data_type, 2,
        0, 8) == 128;
    assert TileCubePayloadIndex(layout, data_type, 2,
        12, 18) == 340;
end;

func TestCubeStageADescriptorPersistence()
begin
    ResetProfileState();
    ConfigureCubeTile(0, 128, 16, 4, TileDataType_U4X2,
        TileLayout_CUBE_M16, TileLocation_Matrix);
    WriteTileElement(0, 0, 3, Zeros{PTO_XLEN} + 0x5a);
    let old_storage_rows = _Tiles[[0]].storage_rows;
    let old_storage_columns = _Tiles[[0]].storage_columns;
    let old_k_repeat = _Tiles[[0]].cube_k_repeat;
    let old_cell_count = _Tiles[[0]].cube_cell_count;
    assert CubeValidRegionUpdateLegal(_Tiles[[0]], 15, 4);
    UpdateCubeTileValidRegion(0, 15, 4);
    assert _Tiles[[0]].storage_rows == old_storage_rows;
    assert _Tiles[[0]].storage_columns == old_storage_columns;
    assert _Tiles[[0]].cube_k_repeat == old_k_repeat;
    assert _Tiles[[0]].cube_cell_count == old_cell_count;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 0x5a;
    assert !CubeValidRegionUpdateLegal(_Tiles[[0]], 15, 17);
    UpdateCubeTileValidRegion(0, 15, 17);
    assert _Tiles[[0]].valid_columns == 4;
    assert _Tiles[[0]].cube_k_repeat == old_k_repeat;
    assert ReadTileElement(0, 0, 3) == Zeros{PTO_XLEN} + 0x5a;
    assert TileDescriptorConfigured(0);
    assert !TileDescriptorLegal(0);
    assert !SharedTileUpdateCompatible(Zeros{8}, _Tiles[[0]], '0001');

    ConfigureTile(1, 128, 16, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    assert _Tiles[[1]].storage_rows == _Tiles[[1]].rows;
    assert _Tiles[[1]].storage_columns == _Tiles[[1]].columns;
    assert TileDescriptorConfigured(1);
end;

func main() => integer
begin
    TestCubeStageAWidthsAndShapes();
    TestCubeStageAM16B4Interleave();
    TestCubeStageABRepeatsAndTails();
    TestCubeStageADescriptorPersistence();
    return 0;
end;
