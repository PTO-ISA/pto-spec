// PTO-TEST: {"id":"PTO-AVS-TILE-TEXP-FP64-002","source":"asl/tile/elementwise-tile-tile/transcendental/TEXP.asl","requirements":["PTO-INST-TILE-TEXP","PTO-TEXP-CONTRACT-001"],"kind":"execution","summary":"TEXP bounds a finite binary64 input before range-reduced evaluation","pass_condition":"maximum finite binary64 produces positive infinity with OF and NX rather than constructing an unbounded real","related_sources":["asl/tile/model/numeric/reference-conversion.asl","asl/arch/state/numeric-status.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 1 looplimit 2 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_FP64, TileLayout_RowMajor);
    end;
    WriteTileElement(0, 0, 0,
        Zeros{PTO_XLEN} + 0x7fefffffffffffff);
    InstructionContractExecute_TEXP(1, 0);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x7ff0000000000000;
    assert NumericStatusFlags() == Zeros{5} + 0x14;
    return 0;
end;
