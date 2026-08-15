// PTO-TEST: {"id":"PTO-AVS-TILE-TAND-BITS-001","source":"asl/tile/elementwise-tile-tile/logical/TAND.asl","requirements":["PTO-INST-TILE-TAND"],"kind":"execution","summary":"TAND computes bitwise AND at the selected element width","pass_condition":"U8 elements 240 and 90 produce 80 with zero carrier bits above bit seven","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 240);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 90);
    assert InstructionContractOperandsLegal_TAND(2, 0, 1);
    InstructionContractExecute_TAND(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 80;
    return 0;
end;
