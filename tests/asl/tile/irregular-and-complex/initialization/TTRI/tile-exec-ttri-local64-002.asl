// PTO-TEST: {"id":"PTO-AVS-TILE-TTRI-LOCAL64-002","source":"asl/tile/irregular-and-complex/initialization/TTRI.asl","requirements":["PTO-INST-TILE-TTRI","PTO-TTRI-CONTRACT-001"],"kind":"execution","summary":"TTRI generates exact 64-bit triangular constants","pass_condition":"FP64, S64, and U64 lower triangles contain their exact typed positive one and zero","related_sources":["asl/tile/model/execution/generation.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 2, 2, 2, 2,
        TileDataType_FP64, TileLayout_RowMajor);
    assert InstructionContractOperandsLegal_TTRI(0, FALSE, 0);
    InstructionContractExecute_TTRI(0, FALSE, 0);
    assert ReadTileElement(0, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3ff0000000000000;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(0, 1, 1) ==
        Zeros{PTO_XLEN} + 0x3ff0000000000000;

    ConfigureTile(1, 128, 2, 2, 2, 2,
        TileDataType_S64, TileLayout_RowMajor);
    ConfigureTile(2, 128, 2, 2, 2, 2,
        TileDataType_U64, TileLayout_RowMajor);
    InstructionContractExecute_TTRI(1, FALSE, 0);
    InstructionContractExecute_TTRI(2, FALSE, 0);
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(2, 1, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};
    return 0;
end;
