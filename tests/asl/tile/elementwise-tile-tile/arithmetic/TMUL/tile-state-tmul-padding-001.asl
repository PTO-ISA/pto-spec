// PTO-TEST: {"id":"PTO-AVS-TILE-TMUL-PADDING-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMUL.asl","requirements":["PTO-INST-TILE-TMUL"],"kind":"state-transition","summary":"TMUL publishes valid products and selected physical padding together","pass_condition":"Min padding is defined with the selected integer minimum while Null padding remains undefined","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func ConfigurePaddedTMULTiles()
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_S64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigurePaddedTMULTiles();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5}, '10',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    InstructionContractExecute_TMUL(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 15;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == '1000000000000000000000000000000000000000000000000000000000000000';

    ResetProfileState();
    ConfigurePaddedTMULTiles();
    InstructionContractExecute_TMUL(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 15;
    assert !TileElementDefined(2, 0, 1);
    return 0;
end;
