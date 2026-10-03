// PTO-TEST: {"id":"PTO-AVS-TILE-TSQRT-FP64-002","source":"asl/tile/elementwise-tile-tile/transcendental/TSQRT.asl","requirements":["PTO-INST-TILE-TSQRT","PTO-TSQRT-CONTRACT-001"],"kind":"execution","summary":"TSQRT computes exact finite binary64 square roots across the exponent range","pass_condition":"binary64 positive four and the minimum subnormal produce positive two and 2^-537 without numeric flags","related_sources":["asl/tile/model/numeric/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 2, 1, 2,
            TileDataType_FP64, TileLayout_RowMajor);
    end;
    WriteTileElement(0, 0, 0,
        Zeros{PTO_XLEN} + 0x4010000000000000);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 1);
    InstructionContractExecute_TSQRT(1, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x4000000000000000;
    assert ReadTileElement(1, 0, 1) ==
        Zeros{PTO_XLEN} + 0x1e60000000000000;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
