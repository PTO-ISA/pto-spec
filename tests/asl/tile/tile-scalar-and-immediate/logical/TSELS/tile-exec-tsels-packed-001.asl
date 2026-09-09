// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-PACKED-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-INST-TILE-TSELS","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Direct TSELS fallback uses the destination operation type for raw cross-carrier selection","pass_condition":"an S32 true source and raw scalar are selected into a TF32 destination without numeric-status effects","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigurePredicateTile(0, 128, 16, 2, 1, 2);
    ConfigureTile(
        1,
        128,
        8,
        2,
        1,
        2,
        TileDataType_S32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        8,
        2,
        1,
        2,
        TileDataType_TF32,
        TileLayout_RowMajor,
        TileLocation_Any);
    // The two predicates share byte zero.  This pattern distinguishes packed
    // bit access from incorrectly treating payload words as one mask per
    // logical element.
    WriteTilePredicateBit(0, 0, 0, FALSE);
    WriteTilePredicateBit(0, 0, 1, TRUE);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7f800001);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 11);

    _SystemRegisters.core_state[36:32] = '00100';
    ExecuteTileSelectScalar(
        2,
        0,
        1,
        Zeros{PTO_XLEN} + 99);

    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 11;
    assert ScalarFPFlags() == '00100';
    return 0;
end;
