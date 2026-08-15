// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-PADDING-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-INST-TILE-TMAX"],"kind":"state-transition","summary":"TMAX applies the selected PadValue outside the valid destination rectangle","pass_condition":"Max defines physical padding with the typed upper bound while omitted PadValue leaves the same coordinates undefined","related_sources":["asl/tile/model/definedness/elements.asl","asl/tile/model/execution/elementwise.asl"]}
func ConfigureTmaxPaddedTiles()
begin
    for index = 0 to 2 looplimit 3 do
        ConfigureTile(index as TileIndex, 128, 8, 2, 1, 1,
            TileDataType_U64, TileLayout_RowMajor, TileLocation_Any);
    end;
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 5);
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTmaxPaddedTiles();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5}, '01',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    InstructionContractExecute_TMAX(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Ones{PTO_XLEN};

    ResetProfileState();
    ConfigureTmaxPaddedTiles();
    InstructionContractExecute_TMAX(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 7;
    assert !TileElementDefined(2, 0, 1);
    return 0;
end;
