// PTO-TEST: {"id":"PTO-AVS-TILE-REDUCTION-CUBE-001","source":"asl/tile/model/execution/reduction.asl","requirements":["PTO-TROWARGMAX-CONTRACT-001","PTO-TROWSUM-CONTRACT-001"],"kind":"execution","summary":"CUBE_M16 and CUBE_M32 reductions preserve the frozen physical destination dimensions and publish logical results.","pass_condition":"M16 and M32 row and column reductions execute, publish exact valid and physical shapes, and return correct numerical values while valid-row limits remain enforced.","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/shape/cube-cell.asl"]}
func FillTile(index: TileIndex, rows: integer {1..65535},
              columns: integer {1..65535})
begin
    for row = 0 to rows - 1 looplimit 65536 do
        for column = 0 to columns - 1 looplimit 65536 do
            WriteTileElement(index,
                row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN} +
                    ((column + 1) as integer {1..65535}));
        end;
    end;
end;

func TestCubeReduction()
begin
    let source_ok = ConfigureCubeTile(0, 2048, 16, 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    let sum_destination = ConfigureCubeTile(1, 128, 16, 1,
        TileDataType_U32, TileLayout_CUBE_M16);
    let arg_destination = ConfigureCubeTile(2, 128, 16, 1,
        TileDataType_U32, TileLayout_CUBE_M16);
    let column_destination = ConfigureCubeTileForMaskWithPhysical(3, 128,
        16, 2, 1, 2, TileDataType_U32, TileLayout_CUBE_M16, '0001');
    assert source_ok && sum_destination && arg_destination &&
           column_destination;
    FillTile(0, 16, 2);
    ExecuteTileReduction(TileReduction_SUM, TileAxis_Row, 1, 0);
    ExecuteTileReduction(TileReduction_ARGMAX, TileAxis_Row, 2, 0);
    ExecuteTileReduction(TileReduction_SUM, TileAxis_Column, 3, 0);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(1, 15, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 15, 0) == Zeros{PTO_XLEN} + 1;
    assert _Tiles[[1]].valid_rows == 16 && _Tiles[[1]].valid_columns == 1;
    assert _Tiles[[1]].rows == 16 && _Tiles[[1]].columns == 2;
    assert _Tiles[[3]].valid_rows == 1 && _Tiles[[3]].valid_columns == 2;
    assert _Tiles[[3]].rows == 16 && _Tiles[[3]].columns == 2;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 16;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 32;

    assert !TileCubeDescriptorShapeLegal(256, 17, 1,
        TileDataType_U32, TileLayout_CUBE_M16);
    assert !TileReductionAndExpansionRowLimitLegal(
        TileLayout_CUBE_M16, 17);

    let source_over_capacity = ConfigureCubeTile(5, 4096, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M16);
    let destination_over_capacity = ConfigureCubeTile(6, 128, 2, 1,
        TileDataType_U32, TileLayout_CUBE_M16);
    assert source_over_capacity && destination_over_capacity;
    FillTile(5, 2, 2);
    assert TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 6, 5);

    let source_m32_ok = ConfigureCubeTileForMaskWithPhysical(7, 512,
        32, 2, 4, 2, TileDataType_U32, TileLayout_CUBE_M32, '0001');
    let destination_m32_row = ConfigureCubeTileForMaskWithPhysical(8, 512,
        32, 2, 4, 1, TileDataType_U32, TileLayout_CUBE_M32, '0001');
    let destination_m32_column = ConfigureCubeTileForMaskWithPhysical(9, 512,
        32, 2, 1, 2, TileDataType_U32, TileLayout_CUBE_M32, '0001');
    assert source_m32_ok && destination_m32_row && destination_m32_column;
    FillTile(7, 4, 2);
    assert TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 8, 7);
    ExecuteTileReduction(TileReduction_SUM, TileAxis_Row, 8, 7);
    ExecuteTileReduction(TileReduction_SUM, TileAxis_Column, 9, 7);
    assert _Tiles[[8]].valid_rows == 4 && _Tiles[[8]].valid_columns == 1;
    assert _Tiles[[8]].rows == 32 && _Tiles[[8]].columns == 2;
    assert _Tiles[[9]].valid_rows == 1 && _Tiles[[9]].valid_columns == 2;
    assert _Tiles[[9]].rows == 32 && _Tiles[[9]].columns == 2;
    assert ReadTileElement(8, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(8, 3, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(9, 0, 1) == Zeros{PTO_XLEN} + 8;

    let source_m32_too_tall = ConfigureCubeTile(10, 256, 33, 1,
        TileDataType_U32, TileLayout_CUBE_M32);
    let destination_m32_too_tall = ConfigureCubeTile(11, 256, 33, 1,
        TileDataType_U32, TileLayout_CUBE_M32);
    assert source_m32_too_tall && destination_m32_too_tall;
    FillTile(10, 33, 1);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 11, 10);
end;

func main() => integer
begin
    ResetProfileState();
    TestCubeReduction();
    return 0;
end;
