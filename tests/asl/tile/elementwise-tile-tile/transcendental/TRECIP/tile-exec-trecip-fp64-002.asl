// PTO-TEST: {"id":"PTO-AVS-TILE-TRECIP-FP64-002","source":"asl/tile/elementwise-tile-tile/transcendental/TRECIP.asl","requirements":["PTO-INST-TILE-TRECIP","PTO-TRECIP-CONTRACT-001"],"kind":"execution","summary":"TRECIP computes an exact finite binary64 reciprocal","pass_condition":"binary64 positive two produces positive one half without numeric flags","related_sources":["asl/tile/model/numeric/reference-conversion.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP64, TileLayout_RowMajor);
    end;
    WriteTileElement(0, 0, 0,
        Zeros{PTO_XLEN} + 0x4000000000000000);
    InstructionContractExecute_TRECIP(1, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3fe0000000000000;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
