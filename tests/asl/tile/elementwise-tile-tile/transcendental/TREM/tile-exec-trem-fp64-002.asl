// PTO-TEST: {"id":"PTO-AVS-TILE-TREM-FP64-002","source":"asl/tile/elementwise-tile-tile/transcendental/TREM.asl","requirements":["PTO-INST-TILE-TREM","PTO-TREM-CONTRACT-001"],"kind":"execution","summary":"TREM computes binary64 remainder with an unbounded exact truncation quotient","pass_condition":"maximum finite binary64 modulo positive one is positive zero without numeric flags","related_sources":["asl/tile/model/numeric/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP64, TileLayout_RowMajor);
    end;
    WriteTileElement(0, 0, 0,
        Zeros{PTO_XLEN} + 0x7fefffffffffffff);
    WriteTileElement(1, 0, 0,
        Zeros{PTO_XLEN} + 0x3ff0000000000000);
    InstructionContractExecute_TREM(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN};
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
