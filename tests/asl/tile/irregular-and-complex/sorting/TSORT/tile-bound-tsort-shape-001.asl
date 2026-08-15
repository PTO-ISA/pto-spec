// PTO-TEST: {"id":"PTO-AVS-TILE-TSORT-SHAPE-001","source":"asl/tile/irregular-and-complex/sorting/TSORT.asl","requirements":["PTO-INST-TILE-TSORT"],"kind":"boundary","summary":"TSORT requires exact row and column shape equality","pass_condition":"equal flattened extents with different logical shapes are rejected","related_sources":["asl/tile/model/legality/indexed-layout.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        20, 256, 1, 4, 1, 4,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        21, 256, 1, 4, 1, 4,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        22, 256, 2, 2, 2, 2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    for row = 0 to 1 do
        for column = 0 to 1 do
            WriteTileElement(
                22,
                row as integer {0..65535},
                column as integer {0..65535},
                Zeros{PTO_XLEN});
        end;
    end;

    assert !TileOperandsLegal_TSORT(20, 21, 22, 2, FALSE);
    return 0;
end;
