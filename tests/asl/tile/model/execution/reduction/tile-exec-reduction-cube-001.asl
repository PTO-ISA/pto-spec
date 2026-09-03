// PTO-TEST: {"id":"PTO-AVS-TILE-REDUCTION-CUBE-001","source":"asl/tile/model/execution/reduction.asl","requirements":["PTO-TROWARGMAX-CONTRACT-001","PTO-TROWSUM-CONTRACT-001"],"kind":"execution","summary":"CUBE_M16 reductions use logical coordinates, return U32 arg indices, and enforce operation-specific row and source-capacity bounds.","pass_condition":"M16 16-row sum and argmax execute with logical results, M16 17-row and 2049-byte-capacity sources reject, and M32 32-row/33-row boundaries are distinguished.","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/shape/cube-cell.asl"]}
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
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let sum_destination = ConfigureCubeTile(1, 128, 16, 1,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let arg_destination = ConfigureCubeTile(2, 128, 16, 1,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source_ok && sum_destination && arg_destination;
    FillTile(0, 16, 2);
    assert TileReductionSourceCapacityLegal(0);
    ExecuteTileReduction(TileReduction_SUM, TileAxis_Row, 1, 0);
    ExecuteTileReduction(TileReduction_ARGMAX, TileAxis_Row, 2, 0);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(1, 15, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 15, 0) == Zeros{PTO_XLEN} + 1;

    assert !TileCubeDescriptorShapeLegal(256, 17, 1,
        TileDataType_U32, TileLayout_CUBE_M16);
    assert !TileReductionAndExpansionRowLimitLegal(
        TileLayout_CUBE_M16, 17);

    let source_over_capacity = ConfigureCubeTile(5, 4096, 2, 2,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    let destination_over_capacity = ConfigureCubeTile(6, 128, 2, 1,
        TileDataType_U32, TileLayout_CUBE_M16, TileLocation_Matrix);
    assert source_over_capacity && destination_over_capacity;
    FillTile(5, 2, 2);
    assert !TileReductionSourceCapacityLegal(5);
    _Tiles[[5]].capacity_bytes = 2049;
    assert !TileReductionSourceCapacityLegal(5);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 6, 5);

    let source_m32_ok = ConfigureCubeTile(7, 128, 32, 1,
        TileDataType_U32, TileLayout_CUBE_M32, TileLocation_Matrix);
    let destination_m32_ok = ConfigureCubeTile(8, 128, 32, 1,
        TileDataType_U32, TileLayout_CUBE_M32, TileLocation_Matrix);
    assert source_m32_ok && destination_m32_ok;
    FillTile(7, 32, 1);
    assert TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 8, 7);

    let source_m32_too_tall = ConfigureCubeTile(9, 256, 33, 1,
        TileDataType_U32, TileLayout_CUBE_M32, TileLocation_Matrix);
    let destination_m32_too_tall = ConfigureCubeTile(10, 256, 33, 1,
        TileDataType_U32, TileLayout_CUBE_M32, TileLocation_Matrix);
    assert source_m32_too_tall && destination_m32_too_tall;
    FillTile(9, 33, 1);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 10, 9);
end;

func main() => integer
begin
    ResetProfileState();
    TestCubeReduction();
    return 0;
end;
