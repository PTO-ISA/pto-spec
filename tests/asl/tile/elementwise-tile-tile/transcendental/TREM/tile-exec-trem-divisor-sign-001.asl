// PTO-TEST: {"id":"PTO-AVS-TILE-TREM-DIVISOR-SIGN-001","source":"asl/tile/elementwise-tile-tile/transcendental/TREM.asl","requirements":["PTO-INST-TILE-TREM"],"kind":"execution","summary":"TREM signed modulo follows the divisor sign","pass_condition":"negative seven modulo positive three is positive two and positive seven modulo negative three is negative two","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 2, 1, 2,
            TileDataType_S64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} - 7);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} - 3);
    assert InstructionContractOperandsLegal_TREM(2, 0, 1);
    InstructionContractExecute_TREM(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} - 2;
    return 0;
end;
