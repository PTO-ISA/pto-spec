// PTO-TEST: {"id":"PTO-AVS-TILE-TROWARGMIN-SHAPE-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWARGMIN.asl","requirements":["PTO-INST-TILE-TROWARGMIN"],"kind":"boundary","summary":"TROWARGMIN requires an exact one-column U32 destination.","pass_condition":"The exact U32 destination is legal while a source-typed destination is rejected.","related_sources":["asl/tile/model/legality/operand-schema.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0,
        128,
        2,
        4,
        2,
        3,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(
                0,
                row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN});
        end;
    end;
    ConfigureTile(
        1,
        128,
        2,
        1,
        2,
        1,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        2,
        1,
        2,
        1,
        TileDataType_S8,
        TileLayout_RowMajor,
        TileLocation_Any);

    assert TileOperandsLegal_ExecuteTileReduction(
        TileReduction_ARGMIN,
        TileAxis_Row,
        1,
        0);
    assert !TileOperandsLegal_ExecuteTileReduction(
        TileReduction_ARGMIN,
        TileAxis_Row,
        2,
        0);
    return 0;
end;
