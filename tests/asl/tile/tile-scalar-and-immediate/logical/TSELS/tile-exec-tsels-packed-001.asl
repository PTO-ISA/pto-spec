// PTO-TEST: {"id":"PTO-AVS-TILE-TSELS-PACKED-001","source":"asl/tile/tile-scalar-and-immediate/logical/TSELS.asl","requirements":["PTO-INST-TILE-TSELS"],"kind":"execution","summary":"TSELS reads packed predicate bits and selects exact Tile or scalar encodings","pass_condition":"one mask bit copies the Tile encoding and zero selects the scalar encoding","related_sources":["asl/tile/model/execution/comparison.asl","asl/tile/model/definedness/elements.asl"]}
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
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        2,
        128,
        8,
        2,
        1,
        2,
        TileDataType_FP32,
        TileLayout_RowMajor,
        TileLocation_Any);
    // The two predicates share byte zero.  This pattern distinguishes packed
    // bit access from incorrectly treating payload words as one mask per
    // logical element.
    WriteTilePredicateBit(0, 0, 0, FALSE);
    WriteTilePredicateBit(0, 0, 1, TRUE);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x7ff8000000000001);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 11);

    ExecuteTileSelectScalar(
        2,
        0,
        1,
        Zeros{PTO_XLEN} + 99);

    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 99;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 11;
    return 0;
end;
