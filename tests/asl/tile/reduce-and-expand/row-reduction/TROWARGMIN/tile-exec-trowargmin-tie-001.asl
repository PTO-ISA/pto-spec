// PTO-TEST: {"id":"PTO-AVS-TILE-TROWARGMIN-TIE-001","source":"asl/tile/reduce-and-expand/row-reduction/TROWARGMIN.asl","requirements":["PTO-INST-TILE-TROWARGMIN"],"kind":"execution","summary":"TROWARGMIN returns the lowest column index among equal minima.","pass_condition":"The first of two equal minima produces U32 index one.","related_sources":["asl/tile/model/execution/reduction.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(
        0, 128, 1, 4, 1, 3,
        TileDataType_U8,
        TileLayout_RowMajor,
        TileLocation_Any);
    ConfigureTile(
        1, 128, 1, 1, 1, 1,
        TileDataType_U32,
        TileLayout_RowMajor,
        TileLocation_Any);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(0, 0, 2, Zeros{PTO_XLEN} + 2);

    assert InstructionContractOperandsLegal_TROWARGMIN(1, 0);
    InstructionContractExecute_TROWARGMIN(1, 0);

    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
