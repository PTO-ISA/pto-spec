// PTO-TEST: {"id":"PTO-AVS-TILE-TRELU-NAN-001","source":"asl/tile/elementwise-tile-tile/logical/TRELU.asl","requirements":["PTO-TRELU-CONTRACT-001"],"kind":"state-transition","summary":"TRELU quiets signaling NaN and records invalid","pass_condition":"FP32 signaling NaN produces the profile quiet NaN and sets only invalid status","related_sources":["asl/tile/model/execution/unary.asl","asl/arch/features/mx-formats.asl","asl/scalar/model/fsu/profile.asl"]}
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
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x7f800001);

    ExecuteTileUnary(TileUnary_RELU, 1, 0);

    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7fc00000;
    assert ScalarFPFlags() == Zeros{5} + 1;
    return 0;
end;
