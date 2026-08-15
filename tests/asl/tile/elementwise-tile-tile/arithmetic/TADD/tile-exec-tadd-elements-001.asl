// PTO-TEST: {"id":"PTO-AVS-TILE-TADD-ELEMENTS-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TADD.asl","requirements":["PTO-INST-TILE-TADD"],"kind":"execution","summary":"TADD adds matching source elements into a new Local destination","pass_condition":"both valid destination elements equal the typed source sums","related_sources":["asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 4, 4, 1, 2,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 9);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);

    assert InstructionContractOperandsLegal_TADD(2, 0, 1);
    InstructionContractExecute_TADD(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 12;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 11;
    return 0;
end;
