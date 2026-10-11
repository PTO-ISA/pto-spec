// PTO-TEST: {"id":"PTO-AVS-TILE-TADDS-SIGNED-ZERO-002","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TADDS.asl","requirements":["PTO-TADDS-CONTRACT-001"],"kind":"execution","summary":"TADDS preserves equal negative-zero signs through the raw FP32 scalar carrier","pass_condition":"an FP32 negative-zero source plus a negative-zero scalar produces negative zero without numeric flags","related_sources":["asl/tile/model/execution/elementwise.asl","asl/scalar/model/fsu/scalar-fp.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 4, 4, 1, 1,
        TileDataType_FP32, TileLayout_RowMajor);
    ConfigureTile(1, 128, 4, 4, 1, 1,
        TileDataType_FP32, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x80000000);

    InstructionContractExecute_TADDS(
        1, 0, Zeros{PTO_XLEN} + 0x80000000);
    assert ReadTileElement(1, 0, 0) ==
        Zeros{PTO_XLEN} + 0x80000000;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
