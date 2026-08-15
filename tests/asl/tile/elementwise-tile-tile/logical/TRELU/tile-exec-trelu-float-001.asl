// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-FLOAT-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"execution","summary":"TRELU maps negative floating values to positive zero","pass_condition":"negative FP32 infinity produces positive zero without numeric status","related_sources":["asl/tile/model/execution/unary.asl","asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(
            index as TileIndex,
            128,
            1,
            1,
            1,
            1,
            TileDataType_FP32,
            TileLayout_RowMajor,
            TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0xff800000);

    ExecuteTileUnary(TileUnary_RELU, 1, 0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN};
    assert ScalarFPFlags() == Zeros{5};
    return 0;
end;
