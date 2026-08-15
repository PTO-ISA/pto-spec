// PTO-TEST: {"id":"PTO-AVS-TILE-TEXP-ZERO-001","source":"asl/tile/elementwise-tile-tile/transcendental/TEXP.asl","requirements":["PTO-INST-TILE-TEXP"],"kind":"execution","summary":"TEXP maps either signed zero to positive one","pass_condition":"FP32 negative zero produces positive one without numeric status flags","related_sources":["asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP32, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x80000000);
    InstructionContractExecute_TEXP(1, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f800000;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
