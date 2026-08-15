// PTO-TEST: {"id":"PTO-AVS-TILE-TXOR-PADDING-001","source":"asl/tile/elementwise-tile-tile/logical/TXOR.asl","requirements":["PTO-INST-TILE-TXOR"],"kind":"state-transition","summary":"TXOR leaves omitted Null padding undefined","pass_condition":"the valid XOR result is defined while every unassigned physical element remains undefined","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func main() => integer
begin
    ResetProfileState();
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 16, 8, 1, 1,
            TileDataType_U8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 10);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 6);
    assert InstructionContractOperandsLegal_TXOR(2, 0, 1);
    InstructionContractExecute_TXOR(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 12;
    assert !TileElementDefined(2, 0, 1);
    return 0;
end;
