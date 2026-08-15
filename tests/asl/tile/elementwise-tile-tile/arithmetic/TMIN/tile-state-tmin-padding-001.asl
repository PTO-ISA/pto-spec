// PTO-TEST: {"id":"PTO-AVS-TILE-TMIN-PADDING-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl","requirements":["PTO-INST-TILE-TMIN"],"kind":"state-transition","summary":"TMIN applies the selected PadValue outside the valid destination rectangle","pass_condition":"Min defines physical padding with the typed lower bound while omitted PadValue leaves the same coordinates undefined","related_sources":["asl/tile/model/definedness/elements.asl","asl/tile/model/execution/elementwise.asl"]}
func ConfigureTminPaddedTiles()
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_S8, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTminPaddedTiles();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5}, '10',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    InstructionContractExecute_TMIN(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 0x80;

    ResetProfileState();
    ConfigureTminPaddedTiles();
    InstructionContractExecute_TMIN(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 5;
    assert !TileElementDefined(2, 0, 1);
    return 0;
end;
