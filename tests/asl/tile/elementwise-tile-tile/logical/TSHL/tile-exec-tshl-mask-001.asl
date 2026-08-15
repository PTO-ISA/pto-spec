// PTO-TEST: {"id":"PTO-AVS-TILE-TSHL-MASK-001","source":"asl/tile/elementwise-tile-tile/logical/TSHL.asl","requirements":["PTO-INST-TILE-TSHL"],"kind":"execution","summary":"TSHL masks each shift count to the selected element width","pass_condition":"U8 count ten uses low three bits and shifts one left by two to produce four","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 10);
    assert InstructionContractOperandsLegal_TSHL(2, 0, 1);
    InstructionContractExecute_TSHL(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 4;
    return 0;
end;
