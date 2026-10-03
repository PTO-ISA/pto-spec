// PTO-TEST: {"id":"PTO-AVS-TILE-TLOG-FP64-002","source":"asl/tile/elementwise-tile-tile/transcendental/TLOG.asl","requirements":["PTO-INST-TILE-TLOG","PTO-TLOG-CONTRACT-001"],"kind":"execution","summary":"TLOG normalizes the complete finite binary64 exponent range","pass_condition":"the minimum positive binary64 subnormal produces the independently encoded logarithm","related_sources":["asl/tile/model/numeric/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP64, TileLayout_RowMajor);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    InstructionContractExecute_TLOG(1, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0xc0874385446d71c3;
    return 0;
end;
