// PTO-TEST: {"id":"PTO-AVS-TILE-TXOR-BITS-001","source":"asl/tile/elementwise-tile-tile/logical/TXOR.asl","requirements":["PTO-INST-TILE-TXOR"],"kind":"execution","summary":"TXOR computes bitwise XOR at the selected element width","pass_condition":"U8 elements 170 and 15 produce 165 with zero carrier bits above bit seven","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 170);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 15);
    assert InstructionContractOperandsLegal_TXOR(2, 0, 1);
    InstructionContractExecute_TXOR(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 165;
    return 0;
end;
