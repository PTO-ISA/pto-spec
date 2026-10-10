// PTO-TEST: {"id":"PTO-AVS-TILE-TCI-LOCAL64-002","source":"asl/tile/irregular-and-complex/initialization/TCI.asl","requirements":["PTO-INST-TILE-TCI","PTO-TCI-CONTRACT-001"],"kind":"execution","summary":"TCI generates a full-width U64 sequence","pass_condition":"an ascending U64 sequence preserves bit 63 and increments modulo 2^64","related_sources":["asl/tile/model/execution/generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2,
        TileDataType_U64, TileLayout_RowMajor);
    assert InstructionContractOperandsLegal_TCI(
        0, Zeros{PTO_XLEN} + 0xffffffffffffffff, FALSE);
    InstructionContractExecute_TCI(
        0, Zeros{PTO_XLEN} + 0xffffffffffffffff, FALSE);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0xffffffffffffffff;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
