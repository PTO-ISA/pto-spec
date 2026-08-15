// PTO-TEST: {"id":"PTO-AVS-TILE-TSUB-PADDING-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TSUB.asl","requirements":["PTO-INST-TILE-TSUB"],"kind":"state-transition","summary":"TSUB applies the selected PadValue outside the valid rectangle","pass_condition":"Zero padding is defined and zero while omitted B.DATR leaves padding undefined","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/definedness/elements.asl"]}
func ConfigurePaddedTSUBTiles()
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
    ConfigurePaddedTSUBTiles();
    SetBundleDataAttributeState(Zeros{5} + 24, Zeros{5}, '00',
        Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    InstructionContractExecute_TSUB(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert TileElementDefined(2, 0, 1);
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN};

    ResetProfileState();
    ConfigurePaddedTSUBTiles();
    InstructionContractExecute_TSUB(2, 0, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert !TileElementDefined(2, 0, 1);
    return 0;
end;
