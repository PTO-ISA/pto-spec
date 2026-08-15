// PTO-TEST: {"id":"PTO-AVS-TILE-TOR-BITS-001","source":"asl/tile/elementwise-tile-tile/logical/TOR.asl","requirements":["PTO-INST-TILE-TOR"],"kind":"execution","summary":"TOR computes bitwise OR at the selected element width","pass_condition":"U8 elements 240 and 15 produce 255 with zero carrier bits above bit seven","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 1, 1, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 240);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 15);
    assert InstructionContractOperandsLegal_TOR(2, 0, 1);
    InstructionContractExecute_TOR(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 255;
    return 0;
end;
