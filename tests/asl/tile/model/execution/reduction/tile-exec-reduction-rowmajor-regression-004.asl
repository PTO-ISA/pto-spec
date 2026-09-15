// PTO-TEST: {"id":"PTO-AVS-TILE-REDUCTION-ROWMAJOR-REGRESSION-004","source":"asl/tile/model/execution/reduction.asl","requirements":["PTO-TROWSUM-CONTRACT-001","PTO-TCOLSUM-CONTRACT-001"],"kind":"execution","summary":"RowMajor reduction destination geometry remains capacity-derived","pass_condition":"RowMajor row and column reductions retain their capacity-derived physical row formulas","related_sources":["asl/tile/model/legality/reduction-and-expansion.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 256, 3, 8, 3, 5,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(1, 128, 4, 1, 3, 1,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 8, 1, 5,
        TileDataType_U32, TileLayout_RowMajor);
    for row = 0 to 2 looplimit 3 do
        for column = 0 to 4 looplimit 5 do
            WriteTileElement(0, row as integer {0..65535},
                column as integer {0..65535}, Zeros{PTO_XLEN});
        end;
    end;
    assert TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Row, 1, 0);
    assert TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM, TileAxis_Column, 2, 0);
    return 0;
end;
