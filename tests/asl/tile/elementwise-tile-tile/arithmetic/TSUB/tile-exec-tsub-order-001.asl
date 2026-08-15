// PTO-TEST: {"id":"PTO-AVS-TILE-TSUB-ORDER-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl","requirements":["PTO-INST-TILE-TSUB"],"kind":"execution","summary":"TSUB subtracts the ordered right source from the ordered left source","pass_condition":"the destination contains source-left minus source-right rather than the reversed result","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 2, 8, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 19);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 7);

    assert InstructionContractOperandsLegal_TSUB(2, 0, 1);
    InstructionContractExecute_TSUB(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 12;
    return 0;
end;
